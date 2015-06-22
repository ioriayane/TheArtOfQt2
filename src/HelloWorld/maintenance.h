#ifndef MAINTENANCE_H
#define MAINTENANCE_H

#include <QObject>
#include <QProcess>

class Maintenance : public QObject
{
  Q_OBJECT

  //プロパティの定義
  Q_PROPERTY(bool hasUpdate READ hasUpdate NOTIFY hasUpdateChanged)
  Q_PROPERTY(QString updateDetail READ updateDetail)
  Q_PROPERTY(bool running READ running NOTIFY runningChanged)
  Q_PROPERTY(QString toolName READ toolName WRITE setToolName NOTIFY toolNameChanged)

public:
  explicit Maintenance(QObject *parent = 0);

  //更新の確認開始
  Q_INVOKABLE void checkUpdate();

  bool hasUpdate() const;         //更新があるかの取得
  void setHasUpdate(const bool has);
  QString updateDetail() const;   //更新の詳細情報
  void setUpdateDetail(const QString &updateDetail);
  bool running() const;           //更新を確認中
  void setRunning(const bool running);
  QString toolName() const;       //メンテツールのパス
  void setToolName(const QString &toolName);

signals:
  void hasUpdateChanged();
  void runningChanged();
  void toolNameChanged();

public slots:
  void processStarted();
  void processFinished(int exitCode, QProcess::ExitStatus exitStatus);
  void processError(QProcess::ProcessError error);

private:
  bool m_hasUpdate;
  QString m_updateDetail;
  bool m_running;
  QString m_toolName;
  QProcess m_process;
};

#endif // MAINTENANCE_H
