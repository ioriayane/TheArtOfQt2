//コンストラクタ
function Component()
{
  //完了ページにレイアウトを追加
  if(installer.isInstaller()){                                       // [1]
    installer.addWizardPageItem(component
                              , "FinishAndOpenForm"
                              , QInstaller.InstallationFinished)      // [2]
  }
  //インストールが完了したときのイベント（つまり完了確認ページが表示されたときのイベント）
  installer.installationFinished.connect(this
                              , Component.prototype.installationFinishedPageIsShown);  // [3]
  //完了ボタンが押されたときのシグナル
  installer.finishButtonClicked.connect(this
                              , Component.prototype.installationFinished)  // [4]

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
    if(installer.isInstaller() && installer.status !== QInstaller.Success){
      //追加したレイアウトのオブジェクト取得
      var form = component.userInterface("FinishAndOpenForm")                      // [5]
      //失敗したので追加した部分全体を非表示
      form.visible = false
    }
  }catch(e){
    print(e)
  }
}

//完了ボタンが押されたときのシグナルハンドラ
Component.prototype.installationFinished = function ()
{
  try{
    if(installer.isInstaller() && installer.status === QInstaller.Success){        // [6]
      //追加したレイアウトのオブジェクト取得
      var form = component.userInterface("FinishAndOpenForm")
      //スキーム(Windowsのみ特別)
      var scheme = "file://"
      if(installer.value("os") === "win"){
        scheme = "file:///"
      }
      //チェック状態を確認して実行
      if(form.openReadmeCheckBox.checked){                                         // [7]
        QDesktopServices.openUrl(scheme + installer.value("TargetDir")
                                        + "/README.txt")                           // [8]
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

