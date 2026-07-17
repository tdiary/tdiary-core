---
name: release checklist
about: 毎回のリリース作業チェックリストを提供する
title: X.Y.Z リリース作業 on YYYY-MM-29
labels: release
assignees: ''

---

リリース作業リスト
- [ ] core の `lib/tdiary/tasks/release.rake` と `.github/workflows/ci.yml` に今回サポートを追加/停止するrubyのバージョンが含まれるか確認、修正する
- [ ] coreおよびblogkitのChangeLogに「release L.M.N」のエントリを追加する
- [ ] 以下のファイルのバージョンをあげてcommitする
  - coreの lib/tdiary/version.rb
  - blogkitの lib/tdiary/blogkit/version.rb
  - contribの lib/tdiary/contrib/version.rb
- [ ] core / blogkit / contrib / theme に tag を打つ (`git pull --tags; git tag vL.M.N; git push origin vL.M.N`)
  - coreはtag pushで `.github/workflows/release.yml` が起動し、trusted publishing で gem を rubygems.org に publish、GitHub Release を自動作成する。`.github/workflows/build-image.yml` が Docker イメージも build/push する
- [ ] coreの [Actions](https://github.com/tdiary/tdiary-core/actions) で Release ワークフローの成功と、rubygems.org / GitHub Release / Docker イメージへの反映を確認する
- [ ] 自動生成された core の [GitHub Release](https://github.com/tdiary/tdiary-core/releases) のノートを必要に応じて加筆する
- [ ] 以下の各リポジトリ配下で`bundle clean; bundle exec rake release` コマンドを実行する (gemを最新にしてrubygemsにアップロード)
  - blogkit
  - contrib
- [ ] (Phase 2 実装までの暫定) full tarball を GitHub Release に添付する場合は、core配下で `bundle exec rake package:stable` を実行し tmp 配下の tar.gz を手動でアップロードする (`package:release` と GITHUB_ACCESS_TOKEN による自動アップロードは廃止。CI での自動生成・添付は別途対応予定)
- [ ] themeのmasterブランチをgh-pagesブランチへmerge、pushする (`git checkout gh-pages; git merge master; git push origin gh-pages`)
- [ ] tdiary.org の以下のエントリーを書く
  - [ダウンロード](https://github.com/tdiary/tdiary.github.io/blob/master/download.md)
  - [サイドバー](https://github.com/tdiary/tdiary.github.io/blob/master/_includes/sidebar.html)
  - [リリースしましたのエントリ](https://github.com/tdiary/tdiary.github.io/tree/master/_posts) (`YYYY-MM-DD-release-L_M_N.md` 形式で)
- [ ] 3ヶ月後の次のリリースの [issue](https://github.com/tdiary/tdiary-core/issues/new) と [project](https://github.com/orgs/tdiary/projects/new) を作る
