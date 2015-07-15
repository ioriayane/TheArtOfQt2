//コンストラクタ
function Component()
{
  //インストールが完了したときのイベント（つまり完了確認ページが表示されたときのイベント）
  installer.installationFinished.connect(this
                                         , Component.prototype.installationFinishedPageIsShown)  // [1]
  //完了ボタンが押されたときのシグナル
  installer.finishButtonClicked.connect(this
                                        , Component.prototype.installationFinished)  // [2]

}

//コンポーネント選択のデフォルト確認
Component.prototype.isDefault = function()
{
  return true
}

//インストール動作を追加
Component.prototype.createOperations = function()
{
  try{
    // createOperationsの基本処理を実行
    component.createOperations()

    if(installer.value("os") === "win"){
      //Readme.txt用のショートカット
      component.addOperation("CreateShortcut"
                             , "@TargetDir@/README.txt"
                             , "@StartMenuDir@/README.lnk"
                             , "workingDirectory=@TargetDir@"
                             , "iconPath=%SystemRoot%/system32/SHELL32.dll"
                             , "iconId=2")
      //実行ファイル用のショートカット
      component.addOperation("CreateShortcut"
                             , "@TargetDir@/HelloWorld.exe"
                             , "@StartMenuDir@/HelloWorld.lnk"
                             , "workingDirectory=@TargetDir@"
                             , "iconPath=@TargetDir@/HelloWorld.exe"
                             , "iconId=0")

    }else if (installer.value("os") == "x11"){
      //ランチャー用アイコン
      component.addOperation("InstallIcons", "@TargetDir@/icons/")
      //実行ファイル用のショートカット
      component.addOperation("CreateDesktopEntry"
                           , "HelloWorld.desktop"
                           , "Type=Application\nExec=@TargetDir@/HelloWorld\nPath=@TargetDir@\n"
                            +"Name=Hello World\nGenericName=Example Application.\n"
                            +"Icon=HelloWorld\nTerminal=false\nCategories=Development"
                           )
    }
  }catch(e){
    print(e)
  }
}

//インストールが完了したときのシグナルハンドラ
Component.prototype.installationFinishedPageIsShown = function ()
{
  try{
    if(installer.status === QInstaller.Success){
      //完了ページにレイアウトを追加
      installer.addWizardPageItem(component
                                  , "OpenFileForm"
                                  , QInstaller.InstallationFinished)      // [3]
    }
  }catch(e){
    print(e)
  }
}

//完了ボタンが押されたときのシグナルハンドラ
Component.prototype.installationFinished = function ()
{
  try{
    if(installer.status === QInstaller.Success){                                   // [4]
      //追加したレイアウトのオブジェクト取得
      var form = component.userInterface("OpenFileForm")                           // [5]
      //スキーム(Windowsのみ特別)
      var scheme = "file://"
      if(installer.value("os") === "win"){
        scheme = "file:///"
      }
      //チェック状態を確認して実行
      if(form.openReadmeCheckBox.checked){                                         // [6]
        QDesktopServices.openUrl(scheme + installer.value("TargetDir")
                                        + "/README.txt")                           // [7]
      }
      if(form.runAppCheckBox.checked){
        QDesktopServices.openUrl(scheme + installer.value("TargetDir")
                                        + "/HelloWorld")
      }
    }
  }catch(e){
    print(e)
  }
}

