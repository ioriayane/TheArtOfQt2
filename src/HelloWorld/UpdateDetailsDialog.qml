import QtQuick 2.4
import QtQuick.Controls 1.3
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.1
import QtQuick.XmlListModel 2.0

Dialog {
  id: root
  width: 450
  height: 250
  title: qsTr("Update Detail")
  //ウインドウをモーダルにする
  modality: Qt.ApplicationModal
  //デフォルトは非表示
  visible: false
  //モデルへのエイリアス
  property alias xml: updateDetailModel.xml
  //YesボタンとNoボタンを配置                             [1]
  standardButtons: StandardButton.Yes | StandardButton.No

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
    anchors.left: parent.left
    anchors.right: parent.right
    spacing: 5
    //案内メッセージ
    Text {
      text: qsTr("The following update was found. Do you want to update?")
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
  }
}
