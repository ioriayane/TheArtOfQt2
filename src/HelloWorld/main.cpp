#include <QApplication>
#include <QQmlApplicationEngine>

#include <QtQml/qqml.h>
#include "maintenancetool.h"

int main(int argc, char *argv[])
{
  QApplication app(argc, argv);

  //メンテナンス機能をQMLエレメントとして登録
  qmlRegisterType<MaintenanceTool>("com.example.plugin.maintenancetool"
                               , 1, 0, "MaintenanceTool");

  QQmlApplicationEngine engine;
  engine.load(QUrl(QStringLiteral("qrc:///main.qml")));

  return app.exec();
}
