import QtQuick 2.2
import QtQuick.Controls 1.1
import QtQuick.Layouts 1.1
import QtQuick.XmlListModel 2.0

ApplicationWindow {
  id: root
  width: 400
  height: 200
  title: qsTr("Update Detail")
  //ウインドウをモーダルにする
  modality: Qt.ApplicationModal
  //デフォルトは非表示
  visible: false
  //モデルへのエイリアス
  property alias xml: updateDetailModel.xml

  //アップデート開始                                  [1]
  signal accepted()
  //アップデートキャンセル
  signal canceled()

  //アップデート情報の明細を管理するモデル                   [2]
  XmlListModel {
    id: updateDetailModel
    query: "/updates/update"
    XmlRole { name: "name"; query: "@name/string()" }
    XmlRole { name: "version"; query: "@version/string()" }
    XmlRole { name: "size"; query: "@size/string()" }
  }
  //アップデート情報を表示
  ColumnLayout {
    anchors.fill: parent
    anchors.margins: 10
    spacing: 5
    //案内メッセージ
    Text {
      text: qsTr("The following update was found.")
    }
    //明細表                                     [3]
    TableView {
      Layout.fillWidth: true    //可能な限り横に広げる
      Layout.fillHeight: true   //可能な限り縦に広げる
      TableViewColumn{ role: "name" ; title: "Name"; width: 200 }
      TableViewColumn{ role: "version"; title: "Version"; width: 80 }
      TableViewColumn{ role: "size"; title: "Size"; width: 80 }
      model: updateDetailModel
    }
    RowLayout {
      Layout.alignment: Qt.AlignRight
      //アップデート開始ボタン                         [4]
      Button {
        text: qsTr("Update")
        onClicked: {
          root.accepted()
          root.close()
        }
      }
      //アップデートキャンセルボタン                      [5]
      Button {
        text: qsTr("Cancel")
        onClicked: {
          root.canceled()
          root.close()
        }
      }
    }
  }
}
