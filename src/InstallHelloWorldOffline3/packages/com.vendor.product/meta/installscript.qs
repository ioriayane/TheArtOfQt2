//コンストラクタ
function Component()
{
  //標準インストールで通らないページを非表示にする。
  installer.setDefaultPageVisible(QInstaller.TargetDirectory, false)
  installer.setDefaultPageVisible(QInstaller.ComponentSelection, false)

  //ロードされたときのシグナル
  component.loaded.connect(this, Component.prototype.loaded)    // [1]
  //ページを追加する
  installer.addWizardPage(component
                        , "StandardOrCustom"
                        , QInstaller.TargetDirectory)           // [2]

  //インストールが完了したときのイベント（つまり完了確認ページが表示されたときのイベント）
  installer.installationFinished.connect(this
                              , Component.prototype.installationFinishedPageIsShown)
  //完了ボタンが押されたときのシグナル
  installer.finishButtonClicked.connect(this
                              , Component.prototype.installationFinished)
}

//コンポーネント選択のデフォルト確認
Component.prototype.isDefault = function()
{
  return true
}

//翻訳が行われたときに実行する処理
Component.prototype.retranslateUi = function()
{
  try{
    //ページのオブジェクトを取得（QWidget）
    var pageW = gui.pageWidgetByObjectName("DynamicStandardOrCustom")
    if(pageW != null){
      //メッセージの一部をアプリ名に変更
      pageW.standardLabel.text = pageW.standardLabel.text.replace("%NAME%"
                                             , installer.value("ProductName")) // [3]
    }
  }catch(e){
    print(e)
  }
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
                                  , QInstaller.InstallationFinished)
    }
  }catch(e){
    print(e)
  }
}

//完了ボタンが押されたときのシグナルハンドラ
Component.prototype.installationFinished = function ()
{
  try{
    if(installer.status === QInstaller.Success){
      //追加したレイアウトのオブジェクト取得
      var form = component.userInterface("OpenFileForm")
      //スキーム(Windowsのみ特別)
      var scheme = "file://"
      if(installer.value("os") === "win"){
        scheme = "file:///"
      }
      //チェック状態を確認して実行
      if(form.openReadmeCheckBox.checked){
        QDesktopServices.openUrl(scheme + installer.value("TargetDir")
                                        + "/README.txt")
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


//ロードされたときのシグナルハンドラ
Component.prototype.loaded = function ()
{
  try{
    //ページのオブジェクトを取得
    var page = gui.pageByObjectName("DynamicStandardOrCustom");                 // [4]
    if(page != null){
      //ページに切り替わったときのシグナル
      page.entered.connect(Component.prototype.dynamicStandardOrCustomEntered) // [5]
      //ページから離れるときのシグナル
      page.left.connect(Component.prototype.dynamicStandardOrCustomLeft)
    }
    //ページのオブジェクトを取得（QWidget）
    var pageW = gui.pageWidgetByObjectName("DynamicStandardOrCustom")          // [6]
    if(pageW != null){
      //標準のラジオボタンの状態がトグルしたときのシグナル
      pageW.standardRadioButton.toggled.connect(
                         Component.prototype.standardRadioButtonToggled)      // [7]
    }
  }catch(e){
    print(e)
  }
}

//ページに切り替わったときのシグナルハンドラ
Component.prototype.dynamicStandardOrCustomEntered = function ()
{
//QMessageBox.information("signal:entered", "title", "entered")
}
//ページから離れるときのシグナルハンドラ
Component.prototype.dynamicStandardOrCustomLeft = function ()
{
//QMessageBox.information("signal:left", "title", "left")
}

//標準のラジオボタンの状態がトグルしたときのシグナルハンドラ
Component.prototype.standardRadioButtonToggled = function (checked)
{
  try{
    //インストール先の選択
    installer.setDefaultPageVisible(QInstaller.TargetDirectory, !checked)     // [8]
    //コンポーネントの選択
    installer.setDefaultPageVisible(QInstaller.ComponentSelection, !checked)
  }catch(e){
    print(e)
  }
}
