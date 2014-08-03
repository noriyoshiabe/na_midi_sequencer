NA MIDI Sequencer
=================

作者の個人使用を目的としたMIDIシーケンサです。

## 動作環境
- OSX Mavericks
- Xcode 5.1 以上 (サーバープログラムのビルドで使用)
- Ruby 2.0 以上
- Audio Units 対応音源


## 初期設定マニュアル

### MIDI環境設定
- 「AUDIO MIDI 設定」を開く /Application/Utilities/Audio Midi Setup.app
- 「ウィンドウ」->「MIDIウィンドウを表示」
- 「IACドライバ」をダブルクリックして、設定ペインを開く
- 「装置はオンライン」にチェック

### Audio Units
Audio UnitsについてはAU Lab + Mac標準のDLSMusicDeviceで動作確認しています。  
AU Lab はいつからかMacに標準で付属しなくなりました。  
以下よりダウンロードして下さい。

[https://www.apple.com/jp/itunes/mastered-for-itunes/](https://www.apple.com/jp/itunes/mastered-for-itunes/)

#### AU Lab設定
- 「AU Lab」を開く
- 「StereoOut」->「Create Document」
- 「Edit」->「Add Audio Unit Instrument」
- 今Addした「Stereo Mix」のActiveChannelをすべてオンに

### サーバープログラムのビルド
- Xcodeでcurses/namidi/namidi.xcodeprojをビルド
- 生成されたnamidi実行ファイルを任意の場所にコピー


## 起動方法
- AU Labを起動しておく
- ターミナルからnamidi(サーバープログラム)を起動
    - 終了時はCTRL-C
- クライアントプログラムのルートディレクトリに移動
    - `cd <リポジトリルート>/curses/sequencer`
- クライアントプログラムの起動
    - `ruby main.rb`


## 生成されるファイル/ディレクトリについて
### ソケット
サーバープログラムは/tmp/namidi.sockでMIDIメッセージを待ち受けます。  
基本的にMIDIメッセージのバイナリデータをそのままIACドライバにスルーしているだけなのでncコマンドでも音は鳴らせます。

### 作業ディレクトリ
クライアントプログラム起動時に~/.namidi/ ディレクトリが無ければ作成します。  
各種設定ファイル(yml)、コマンドヒストリ、ログファイル(現状、開発時以外は何も出していない)が置かれます。

### 保存ディレクトリ
クライアントプログラムで作成した楽曲データを保存するディレクトリです。  
デフォルトは~/namidi/ ディレクトリで無ければ作成します。  
~/.namidi/settings.ymlの設定で変更できます。


## 使い方
[オペレーションマニュアル](./docs/operation.md) を参照


## 制限事項

### ターミナル設定
作者のターミナル設定が、背景黒、文字色白、端末サイズが画面一杯となっていて、それ以外の設定で動作確認していません。  
そのため、ターミナル設定によっては使用が困難かもしれません。

### キーボード
作者のキーボードがUSキーボードのため、JISキーボードでは一部機能が正常に動作しない、もしくは使いにくいかもしれません。  
key_mapping.ymlで適宜変更して下さい。


## 今後の予定
- 原則、作者かご近所さんが使っていて不便を感じなければ機能追加はしない
- コマンド入力インタフェースの実装がやっつけなのでどうにかする
- もし使いたい人が出てきたら、Rubyだと配布しにくいのでバイナリにできる開発言語で全部書き直す


## DSL版について
<リポジトリルート>/dsl 以下は2012年に開発したRubyの内部DSLで記述した楽曲データを再生するプログラムです。
初めて書いたRubyコードと、やっつけで書いたCコードをメンテナンスしていません。  
私か[前職同僚](https://github.com/masaori)の気が向けば、コンセプトだけ残して作りなおすかもしれません。  

[README](./dsl/readme.md)
