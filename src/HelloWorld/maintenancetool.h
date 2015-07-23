#ifndef MAINTENANCE_H
#define MAINTENANCE_H

#include <QtCore/QObject>
#include <QtCore/QProcess>

class MaintenanceTool : public QObject
{
  Q_OBJECT

  //列挙型の公開                                                      [1]
  Q_ENUMS(ProcessState)
  Q_ENUMS(StartMode)
  //プロパティの公開
  Q_PROPERTY(ProcessState state READ state NOTIFY stateChanged)
  Q_PROPERTY(bool hasUpdate READ hasUpdate NOTIFY hasUpdateChanged)
  Q_PROPERTY(QString updateDetails READ updateDetails NOTIFY updateDetailsChanged)

public:
  explicit MaintenanceTool(QObject *parent = 0);

  enum ProcessState { //プロセスの実行状態
    NotRunning,
    Running
  };
  enum StartMode {    //メンテナンスツール実行時のモード設定
    CheckUpdate,
    Updater
  };

  ProcessState state() const;                         //メンテツールの状態
  bool hasUpdate() const;                             //更新があるか
  QString updateDetails() const;                      //更新の詳細情報

signals:
  //値が変化したときのシグナル
  void stateChanged(ProcessState state);
  void hasUpdateChanged(bool hasUpdate);
  void updateDetailsChanged(const QString &updateDetails);

public slots:
  void checkUpdate();                                 //更新の確認開始
  void startMaintenanceTool(StartMode mode = Updater);

private slots:
  void setHasUpdate(bool hasUpdate);                  //更新があるか
  void setUpdateDetails(const QString &updateDetails);//更新の詳細情報
  //プロセスの動作に関連するスロット
  void processStarted();
  void processFinished(int exitCode, QProcess::ExitStatus exitStatus);
  void processError(QProcess::ProcessError error);

private:
  ProcessState m_state;
  bool m_hasUpdate;
  QString m_updateDetails;
  QProcess m_process;

  void setState(ProcessState state);                  //メンテツールの状態
};

#endif // MAINTENANCE_H
