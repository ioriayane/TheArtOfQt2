import QtQuick 2.2
import QtQuick.Controls 1.1
import QtQuick.Dialogs 1.2
import com.example.plugin.maintenance 1.0

ApplicationWindow {
  visible: true
  width: 640
  height: 480
  title: qsTr("Hello World")

  //メンテナンス機能
  Maintenance {
    id: mainte
    //アップデート確認の自動実行中かフラグ
    property bool automatically: false

    //メンテツールのファイル名
    toolName: "setuptool.exe"

    onHasUpdateChanged: {
      //アップデートがあるかの状態が変化した
      console.debug("found update:" + hasUpdate)
      if(hasUpdate){
        //アップデートが見つかった
        console.debug("detail:" + updateDetail)
        updateDetailDlg.xml = updateDetail
        updateDetailDlg.show()
      }
    }
    onRunningChanged: {
      //実行状態が変化した
      console.debug("running:" + running)
      if(!running && !hasUpdate){
        //停止したときに見つかっていない
        if(!automatically){
          //ただし自動実行じゃないとき
          notFoundDlg.open()
        }
      }
    }
  }

  //アップデート確認の自動実行用のタイマー
  Timer {
    interval: 2000
    repeat: false
    running: true
    onTriggered: {
      mainte.automatically = true
      mainte.checkUpdate()
    }
  }

  menuBar: MenuBar {
    Menu {
      title: qsTr("File")
      MenuItem {
        text: qsTr("Check update")
        onTriggered: {
          mainte.automatically = false
          mainte.checkUpdate()
        }
      }
      MenuItem {
        text: qsTr("Exit")
        onTriggered: Qt.quit()
      }
    }
  }

  Text {
    text: qsTr("Hello World")
    anchors.centerIn: parent
  }

  //アップデート確認ダイアログ
  UpdateDetailDialog {
    id: updateDetailDlg
    onAccepted: { console.debug("Want update!") }
    onCanceled: { console.debug("No thank you") }
  }
  //見つからなかった時の案内
  MessageDialog {
    id: notFoundDlg
    title: qsTr("Notification")
    text: qsTr("Not found update.")
    standardButtons: StandardButton.Ok
  }
}
