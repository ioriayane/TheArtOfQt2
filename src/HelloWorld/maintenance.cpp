#include "maintenance.h"
#include <QCoreApplication>
#include <QDebug>

Maintenance::Maintenance(QObject *parent) :
  QObject(parent)
, m_hasUpdate(false)
, m_updateDetail(QString())
, m_running(false)
, m_toolName(QString())
, m_process()
{
  //プロセスが終了
  connect(&m_process, SIGNAL(finished(int, QProcess::ExitStatus)), this, SLOT(processFinished(int, QProcess::ExitStatus)) );
  //プロセスがエラー
  connect(&m_process, SIGNAL(started()), this, SLOT(processStarted()));
}

//更新の確認開始
void Maintenance::checkUpdate()
{
  if(toolName().length() == 0){
    qDebug() << "Please set tool name.";
    return;
  }

  //フルパスを作成（カレントがどこにあるかわからないので）
  QString path;
  path = QCoreApplication::applicationDirPath();
  path.append("/");
  path.append(toolName());

  //アップデート確認用のパラメータを設定
  QStringList args;
  args.append("--checkupdates");

  //プロセスが動いてなかったら実行
  if(m_process.state() == QProcess::NotRunning){
    m_process.start(path, args);
  }else{
    qDebug() << "not start";
  }
}

//更新があるかの取得
bool Maintenance::hasUpdate() const
{
  return m_hasUpdate;
}
void Maintenance::setHasUpdate(const bool has)
{
  if(m_hasUpdate == has)  return;
  m_hasUpdate = has;
  emit hasUpdateChanged();
}
//更新の詳細情報
QString Maintenance::updateDetail() const
{
  return m_updateDetail;
}
void Maintenance::setUpdateDetail(const QString &updateDetail)
{
  m_updateDetail = updateDetail;
}
//更新を確認中
bool Maintenance::running() const
{
  return m_running;
}
void Maintenance::setRunning(const bool running)
{
  if(m_running == running)  return;
  m_running = running;
  emit runningChanged();
}
//メンテツールのパス
QString Maintenance::toolName() const
{
  return m_toolName;
}
void Maintenance::setToolName(const QString &toolPath)
{
  if(m_toolName.compare(toolPath) == 0) return;
  m_toolName = toolPath;
  emit toolNameChanged();
}

//プロセスが開始
void Maintenance::processStarted()
{
  setRunning(true);
}
//プロセスが終了
void Maintenance::processFinished(int exitCode, QProcess::ExitStatus exitStatus)
{
  qDebug() << "RecordingThread::processFinished , exitCode=" << exitCode << ", exitStatus=" << exitStatus;

  QByteArray std_out = m_process.readAllStandardOutput();
  QByteArray std_err = m_process.readAllStandardError();
  QString std_out_str = QString::fromLocal8Bit(std_out);
  QString std_err_str = QString::fromLocal8Bit(std_err);
  qDebug() << "out>" << std_out_str;
  qDebug() << "err>" << std_err_str;

  if(exitCode == 0){
    //RecordingThread::processFinished , exitCode= 0 , exitStatus= 0
    //out> "[0] Warning: Could not create lock file 'C:/Program Files (x86)/HelloWorld/lockmyApp15021976.lock': アクセスが拒否されました。
    // (0x00000005)
    //<updates>
    //    <update version="0.3.0-1" name="The root component" size="175748"/>
    //</updates>
    //
    //"
    //err> ""

    //アップデート情報のタグ部分だけ抽出する
    QString xml_str;
    QStringList lines;
    bool enable = false;
    lines = std_out_str.split("\n");
    foreach (QString line, lines) {
      if(line.contains("<updates>")){
        enable = true;
        xml_str.append(line);
      }else if(line.contains("</updates>")){
        xml_str.append(line);
        enable = false;
      }else if(enable){
        xml_str.append(line);
      }else{
      }
    }
    //取得した情報などを設定
    setUpdateDetail(xml_str);
    setHasUpdate(true);

  }else{
    //RecordingThread::processFinished , exitCode= 1 , exitStatus= 0
    //out> "[0] Warning: Could not create lock file 'C:/Program Files (x86)/HelloWorld/lockmyApp15021976.lock': アクセスが拒否されました。
    // (0x00000005)
    //"
    //err> "There are currently no updates available.
    //"
    setHasUpdate(false);
  }
  //停止状態に変更
  setRunning(false);
}
//プロセスがエラー
void Maintenance::processError(QProcess::ProcessError error)
{
  qDebug() << "RecordingThread::processError " << error;
  setRunning(false);
}




