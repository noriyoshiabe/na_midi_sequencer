#初期設定マニュアル(OSX Lion~)

##環境
###Ruby
- ruby 1.9系推奨

###Xcode
- xcode 4.2以上

##設定
###MIDI環境設定
- 「AUDIO MIDI 設定」を開く /Application/Utilities/Audio Midi Setup.app
- 「ウィンドウ」->「MIDIウィンドウを表示」
- 「IACドライバ」をダブルクリックして、設定ペインを開く
- 「装置はオンライン」にチェック

###AU Lab設定
- 「AU Lab」を開く /Developer/Application/Audio/AU Lab.app
- 「StereoOut」->「Create Document」
- 「Edit」->「Add Audio Unit Instrument」
- 今Addした「Stereo Mix」のActiveChannelをすべてオンに

##使い方
###ビルド
- midi.xcodeproj開く
- My Mac 64 bitでビルド
- 生成される midi 実行ファイルをmidi.rbと同じフォルダにコピー

###楽曲データ作成
- マニュアル -> (作成中)
- sample/以下を参考に

###再生
	ruby midi.rb YourData.rb | ./midi