#include <QApplication>
#include <QQmlApplicationEngine>

#include <QtQml>
#include "maintenance.h"

int main(int argc, char *argv[])
{
  QApplication app(argc, argv);

  //メンテナンス機能をQMLエレメントとして登録
  qmlRegisterType<Maintenance>("com.example.plugin.maintenance"
                               , 1, 0, "Maintenance");

  QQmlApplicationEngine engine;
  engine.load(QUrl(QStringLiteral("qrc:///main.qml")));

  return app.exec();
}
