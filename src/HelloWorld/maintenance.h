#ifndef MAINTENANCE_H
#define MAINTENANCE_H

#include <QObject>
#include <QProcess>

class Maintenance : public QObject
{
  Q_OBJECT

  //列挙型の公開                                                      [1]
  Q_ENUMS(ProcessState)
  //プロパティの公開
  Q_PROPERTY(ProcessState state READ state WRITE setState NOTIFY stateChanged)
  Q_PROPERTY(bool hasUpdate READ hasUpdate)
  Q_PROPERTY(QString updateDetail READ updateDetail)
  Q_PROPERTY(QString toolName READ toolName WRITE setToolName)

public:
  explicit Maintenance(QObject *parent = 0);

  enum ProcessState{
    STOP,
    RUNNING,
    FINISH
  };

  Q_INVOKABLE void checkUpdate();                     //更新の確認開始 [2]
  Q_INVOKABLE void startMaintenanceTool(bool checkupdate = false);
                                                      //メンテナンスツール起動

  ProcessState state() const;                        //メンテツールの状態
  void setState(const ProcessState &state);
  bool hasUpdate() const;                             //更新があるかの取得
  void setHasUpdate(const bool has);
  QString updateDetail() const;                       //更新の詳細情報
  void setUpdateDetail(const QString &updateDetail);
  QString toolName() const;                           //メンテツールのパス
  void setToolName(const QString &toolName);

signals:
  //値が変化したときのシグナル
  void stateChanged();

public slots:
  //プロセスの動作に関連するスロット
  void processStarted();
  void processFinished(int exitCode, QProcess::ExitStatus exitStatus);
  void processError(QProcess::ProcessError error);

private:
  ProcessState m_state;
  bool m_hasUpdate;
  QString m_updateDetail;
  QString m_toolName;
  QProcess m_process;
};

#endif // MAINTENANCE_H
