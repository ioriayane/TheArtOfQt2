//コンストラクタ
function Component()
{

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

    if(systemInfo.productType === "windows"){
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

    }else if(systemInfo.productType == "opensuse"){
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
