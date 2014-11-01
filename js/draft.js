/*
 * draft.js: save draft data to Web Storage automatically
 * 
 * Copyright (c) MATSUOKA Kohei <http://www.machu.jp/>
 * Distributed under the GPL2 or any later version.
 */
$(function() {

if (!localStorage) { return; }

var Draft = function(storage, text) {
  // 保存先のストレージ
  this.storage = storage;
  // 下書きの保存件数
  this.maxCount = 10;
  // 下書き一覧
  this.items = [];

  this.initialize(text);
};

Draft.prototype = {
  // ローカルストレージから下書きを読み込む
  initialize: function(text) {
    this.items = this.storage.drafts ? JSON.parse(this.storage.drafts) : new Array();
    // 下書きに空の日記・テキストエリアと同じ日記が存在すれば削除する
    this.items = $.grep(this.items, function(item, index) {
      // 改行と空白文字を無視して比較（プレビュー時に末尾へ改行が付加されるため)
      if (item.value == "" || DraftUtils.trim(item.value) == DraftUtils.trim(text)) {
        return false;
      }
      return true;
    });
    this.save(text, true);
    // console.log("Draft.initialized");
  },

  // ローカルストレージに下書きを保存する
  // append が true の場合は、下書き一覧の末尾に追加する
  // append が false の場合は、最後の下書きに上書きする
  save: function(text, append) {
    if (!append) {
      this.items.pop();
    }
    this.items.push({
      date: new Date().getTime(),
      value: text
    });
    // 最大でmaxCount件数の履歴を保持
    if (this.items.length > this.maxCount) {
      this.items.shift();
    }
    this.storage.drafts = JSON.stringify(this.items);
  },

  // 下書き一覧から index 番目の下書きを取得する
  // 取得した下書きは一覧の末尾に移動する
  load: function(index) {
    var item = this.items.splice(index, 1)[0];
    this.items.push(item);
    return item.value;
  },

  // 下書きのタイトル一覧の配列を返す（表示用）
  // タイトルは textarea の先頭1行目 + 更新日時
  titles: function() {
    return $.map(this.items, function(item) {
      var date = new Date(item.date);
      date = DraftUtils.dateToString(date);
      var title = "No-Name";
      if (item.value && typeof item.value == "string") {
        title = item.value.match(/.*/)[0];
      }
      return title + " (" + date + ")";
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
  }
};

// ---------------------------------------
// ここからDOMの初期化処理
// ---------------------------------------

// 保存対象のテキストエリア
var textarea = $("[name=body]");
// 下書き一覧を表示するセレクトボックス
var select = $("[name=drafts]");
// 自動保存の間隔（ミリ秒）
var autoSaveInterval = 5 * 1000;

var draft = new Draft(localStorage, textarea.val());

// 下書き保存
saveDraft = function() {
  draft.save(textarea.val());
  showSelectForm(true);
};
// 下書き読み込み
loadDraft = function() {
  textarea.val(draft.load(select.val()));
  showSelectForm(false);
};
// 下書き選択用のセレクトボックスを描画
showSelectForm = function(keepIndex) {
  var index = select.val();
  select.empty();
  $.each(draft.titles(), function(i, title) {
    select.append($("<option/>").attr("value", i).text(title));
    select.val(i);
  });
  if (keepIndex) {
    select.val(index);
  }
};

// DOMイベント設定
$("#draft_load").click(loadDraft);
setInterval(saveDraft, autoSaveInterval);
textarea.change(saveDraft);

showSelectForm(false);
// console.log("ready");

});
