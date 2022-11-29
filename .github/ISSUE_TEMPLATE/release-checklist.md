---
name: release checklist
about: 毎回のリリース作業チェックリストを提供する
title: X.Y.Z リリース作業 on YYYY-MM-29
labels: release
assignees: ''

---

リリース作業リスト
- [ ] lib/tdiary/tasks/release.rake` と `.github/workflow/ci.yml` に今回サポートを追加/停止するrubyのバージョンが含まれるか確認、修正する
- [ ] [releases](https://github.com/tdiary/tdiary-core/releases)にエントリを追加してリリースノートを書く
- [ ] coreおよびblogkitのChangeLogに「release L.M.N」のエントリを追加する
- [ ] 以下のファイルのバージョンをあげてcommitする
  - coreの lib/tdiary/version.rb
  - blogkitの lib/tdiary/blogkit/version.rb
  - contribの lib/tdiary/contrib/version.rb
- [ ] core / blogkit / contrib / theme に tag を打つ (`git pull --tags; git tag vL.M.N; git push origin vL.M.N`)
- [ ] 以下の各リポジトリ配下で`bundle clean; bundle exec rake release` コマンドを実行する (gemを最新にしてrubygemsにアップロード)
  - core
  - blogkit
  - contrib
- [ ] core配下で`bundle exec rake package:stable package:release` コマンドを実行する(GitHub に tar.gz をアップロードする。GITHUB_ACCESS_TOKEN環境変数が必要なので注意, see #573)
- [ ] themeのmasterブランチをgh-pagesブランチへmerge、pushする (`git checkout gh-pages; git merge master; git push origin gh-pages`)
- [ ] core配下で `docker build . -t tdiary/tdiary:L.M.N` を実行してから、`push` する (`L.M`, `L`, `latest` も同様)
- [ ] tdiary.org の以下のエントリーを書く
  - [ダウンロード](https://github.com/tdiary/tdiary.github.io/blob/master/download.md)
  - [サイドバー](https://github.com/tdiary/tdiary.github.io/blob/master/_includes/sidebar.html)
  - [リリースしましたのエントリ](https://github.com/tdiary/tdiary.github.io/tree/master/_posts) (`YYYY-MM-DD-release-L_M_N.md` 形式で)
- [ ] 3ヶ月後の次のリリースの [issue](https://github.com/tdiary/tdiary-core/issues/new) と [project](https://github.com/orgs/tdiary/projects/new) を作る
