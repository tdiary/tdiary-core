/*
 * draft.js: save draft data to Web Storage automatically
 *           and keep a copy of them on the server
 *
 * Copyright (c) MATSUOKA Kohei <http://www.machu.jp/>
 * Distributed under the GPL2 or any later version.
 */
$(function() {

if (!localStorage) { return; }

var Draft = function(storage, text, server) {
  // 保存先のストレージ
  this.storage = storage;
  // 下書きの保存件数
  this.maxCount = server.max;
  // 下書き一覧
  this.items = [];
  // このページで編集している下書きの ID
  this.current = null;
  // 最後に保存したテキストエリアの内容
  this.text = text;
  // サーバーにある下書きの ID と更新日時
  this.synced = {};

  this.initialize(text, server);
};

Draft.prototype = {
  // ローカルストレージの下書きにサーバーの下書きを統合する
  initialize: function(text, server) {
    var items = this.storage.drafts ? JSON.parse(this.storage.drafts) : new Array();
    var synced = this.synced;
    $.each(items, function(index, item) {
      if (!item.id) { item.id = DraftUtils.newId(); }
    });
    $.each(server.drafts, function(index, remote) {
      synced[remote.id] = remote.date;
      var local = DraftUtils.find(items, remote.id);
      if (!local) {
        items.push(remote);
      } else if (local.date < remote.date) {
        local.date = remote.date;
        local.value = remote.value;
      }
    });
    // 空の下書きと、日記として投稿済みの下書きを削除する
    this.items = $.grep(items, function(item) {
      return typeof item.value == "string" && DraftUtils.trim(item.value) != "" &&
        $.inArray(item.id, server.deleted) < 0;
    });
    this.truncate();
    // テキストエリアと同じ下書きがあれば、それを続けて編集する
    // 改行と空白文字を無視して比較（プレビュー時に末尾へ改行が付加されるため)
    var trimmed = DraftUtils.trim(text);
    var same = $.grep(this.items, function(item) {
      return DraftUtils.trim(item.value) == trimmed;
    });
    if (trimmed != "" && same.length > 0) {
      this.current = same.pop().id;
    }
    this.store();
    // console.log("Draft.initialized");
  },

  // 編集している下書きを更新する
  // テキストエリアの内容が変わっていなければ何もしない
  save: function(text) {
    if (text == this.text) { return; }
    this.text = text;
    if (DraftUtils.trim(text) == "") { return; }
    var item = DraftUtils.find(this.items, this.current);
    if (item) {
      this.items.splice($.inArray(item, this.items), 1);
    } else {
      item = { id: DraftUtils.newId() };
      this.current = item.id;
    }
    item.date = new Date().getTime();
    item.value = text;
    this.items.push(item);
    this.truncate();
    this.store();
  },

  // 指定した下書きを読み込み、それを続けて編集する
  load: function(id) {
    var item = DraftUtils.find(this.items, id);
    if (!item) { return null; }
    this.current = item.id;
    this.text = item.value;
    return item.value;
  },

  // サーバーにまだ無い版の下書き一覧を返す
  pending: function() {
    var synced = this.synced;
    return $.grep(this.items, function(item) {
      return !(synced[item.id] >= item.date);
    });
  },

  // サーバーへ保存した下書きを記録する
  markSynced: function(items) {
    var synced = this.synced;
    $.each(items, function(index, item) {
      synced[item.id] = item.date;
    });
  },

  // 最大でmaxCount件数の履歴を保持
  truncate: function() {
    this.items.sort(function(a, b) { return a.date - b.date; });
    this.items = this.items.slice(-this.maxCount);
  },

  store: function() {
    this.storage.drafts = JSON.stringify(this.items);
  },

  // 下書きの ID とタイトルの一覧を返す（表示用）
  // タイトルは textarea の先頭1行目 + 更新日時
  titles: function() {
    return $.map(this.items, function(item) {
      var date = DraftUtils.dateToString(new Date(item.date));
      var title = item.value.match(/.*/)[0] || "No-Name";
      return { id: item.id, title: title + " (" + date + ")" };
    });
  }

};

// ユーティリティ関数
var DraftUtils = {
  // 日付を YYYY-mm-dd HH:MM:SS 形式に変換する
  dateToString: function(date) {
      var d = date || new Date();
      var year = d.getFullYear();
      var month = zp(d.getMonth() + 1);
      date = zp(d.getDate());
      var hour = zp(d.getHours());
      var min = zp(d.getMinutes());
      var sec = zp(d.getSeconds());
      return year + "-" + month + "-" + date + " " + hour + ":" + min + ":" + sec;

      function zp(s, l) {
        s = String(s); l = l || 2;
        while (s.length < l) { s = "0" + s; }
        return s;
      }
  },
  // 文字列から改行と空白文字を取り除く
  trim: function(str) {
    return str.replace(/\s+/g, "");
  },
  // 下書きの ID を作る（サーバーが受け付けるのは英小文字と数字のみ）
  newId: function() {
    return new Date().getTime().toString(36) + Math.random().toString(36).slice(2, 10);
  },
  find: function(items, id) {
    return $.grep(items, function(item) { return item.id == id; })[0];
  }
};

// ---------------------------------------
// ここからDOMの初期化処理
// ---------------------------------------

// 保存対象のテキストエリア
var textarea = $("[name=body]");
// 日記の更新フォーム
var form = textarea.closest("form");
// 下書き一覧を表示するセレクトボックス
var select = $("[name=drafts]");
// 自動保存の間隔（ミリ秒）
var autoSaveInterval = 5 * 1000;
// サーバーへ保存する間隔（ミリ秒）
var syncInterval = $tDiary.plugin.draft.interval * 1000;

var draft = new Draft(localStorage, textarea.val(), $tDiary.plugin.draft.server);
var syncing = false;

// 下書き保存
saveDraft = function() {
  draft.save(textarea.val());
  showSelectForm(true);
};
// 下書き読み込み
loadDraft = function() {
  var value = draft.load(select.val());
  if (value != null) {
    textarea.focus();
    $.replaceText(textarea[0], value, 0, textarea.val().length);
  }
  showSelectForm(false);
};
// サーバーに無い下書きをサーバーへ保存
syncDraft = function(keepalive) {
  var items = $.map(draft.pending(), function(item) {
    return { id: item.id, date: item.date, value: item.value };
  });
  if (syncing || items.length == 0) { return; }
  var params = new URLSearchParams();
  params.append("plugin", "draft");
  params.append("plugin_draft_sync", JSON.stringify(items));
  form.find("[name=csrf_protection_key]").each(function() {
    params.append("csrf_protection_key", $(this).val());
  });
  syncing = true;
  fetch(form.attr("action"), { method: "POST", body: params, keepalive: keepalive })
    .then(function(response) {
      if (response.ok) { draft.markSynced(items); }
    }, function() {})
    .then(function() { syncing = false; });
};
// 下書き選択用のセレクトボックスを描画
showSelectForm = function(keepSelection) {
  var selected = select.val();
  select.empty();
  $.each(draft.titles(), function(i, item) {
    select.append($("<option/>").attr("value", item.id).text(item.title));
  });
  if (!(keepSelection && selected)) {
    selected = draft.current || select.children().last().val();
  }
  select.val(selected);
};

// DOMイベント設定
$("#draft_load").click(loadDraft);
setInterval(saveDraft, autoSaveInterval);
setInterval(function() { syncDraft(false); }, syncInterval);
textarea.change(saveDraft);
// タブを閉じる・切り替える前に保存する
$(document).on("visibilitychange", function() {
  if (document.visibilityState == "hidden") {
    saveDraft();
    syncDraft(true);
  }
});
// 日記として投稿する下書きをサーバーに知らせる
form.submit(function() {
  saveDraft();
  $("[name=plugin_draft_id]").val(draft.current || "");
});

showSelectForm(false);
// console.log("ready");

});
