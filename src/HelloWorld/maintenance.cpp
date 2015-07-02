#include "maintenance.h"
#include <QCoreApplication>
#include <QDebug>

Maintenance::Maintenance(QObject *parent) :
  QObject(parent)
, m_state(STOP)
, m_hasUpdate(false)
, m_updateDetail(QString())
, m_toolName(QString())
, m_process()
{
  //プロセスが開始時のシグナル
  connect(&m_process, SIGNAL(started()), this, SLOT(processStarted()));
  //プロセスが終了時のシグナル
  connect(&m_process, SIGNAL(finished(int, QProcess::ExitStatus))
          , this, SLOT(processFinished(int, QProcess::ExitStatus)));
  //プロセスがエラー終了時のシグナル
  connect(&m_process, SIGNAL(error(QProcess::ProcessError))
          , this, SLOT(processError(QProcess::ProcessError)));
}

//更新の確認開始
void Maintenance::checkUpdate()
{
  startMaintenanceTool(true);
}

void Maintenance::startMaintenanceTool(bool checkupdate)
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

  if(checkupdate){
    //アップデート確認用のパラメータを設定                            [1]
    QStringList args;
    args.append("--checkupdates");

    //プロセスが動いてなかったら実行
    if(m_process.state() == QProcess::NotRunning){
      m_process.start(path, args);
    }else{
      qDebug() << "Already started.";
    }
  }else{
    //メンテツールの通常起動はプロセス管理しない                       [2]
    QProcess::startDetached(path);
  }
}
//メンテツールの状態
Maintenance::PROCESS_STATE Maintenance::state() const
{
  return m_state;
}
void Maintenance::setState(const Maintenance::PROCESS_STATE &state)
{
  if(m_state == state)  return;
  m_state = state;
  emit stateChanged();
}
//更新があるかの取得
bool Maintenance::hasUpdate() const
{
  return m_hasUpdate;
}
void Maintenance::setHasUpdate(const bool has)
{
  m_hasUpdate = has;
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
//メンテツールのパス
QString Maintenance::toolName() const
{
  return m_toolName;
}
void Maintenance::setToolName(const QString &toolPath)
{
  m_toolName = toolPath;
}

//プロセスが開始
void Maintenance::processStarted()
{
  setState(Maintenance::RUNNING);
}
//プロセスが終了
void Maintenance::processFinished(int exitCode, QProcess::ExitStatus exitStatus)
{
  qDebug() << "Maintenance::processFinished , exitCode=" << exitCode << ", exitStatus=" << exitStatus;

  //取得した情報などをクリア
  setUpdateDetail(QString());
  setHasUpdate(false);

  if(exitCode == 0){
    //アップデートあり

    //標準出力を取得する                                         [3]
    QByteArray std_out = m_process.readAllStandardOutput();
    QString std_out_str = QString::fromLocal8Bit(std_out);
    qDebug() << "out>" << std_out_str;
    //Maintenance::processFinished , exitCode= 0 , exitStatus= 0
    //out> "[0] Warning: Could not create lock file 'C:/Program Files (x86)/HelloWorld/lockmyApp15021976.lock': アクセスが拒否されました。
    // (0x00000005)
    //<updates>
    //    <update version="0.3.0-1" name="The root component" size="175748"/>
    //</updates>
    //
    //"
    //err> ""

    //アップデート情報のタグ部分だけ抽出する                             [4]
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
    if(xml_str.length() > 0){
      setUpdateDetail(xml_str);
      setHasUpdate(true);
    }
    //停止状態に変更
    setState(Maintenance::FINISH);

  }else if(exitCode == 1){
    //アップデートなし
    QByteArray std_err = m_process.readAllStandardError();
    QString std_err_str = QString::fromLocal8Bit(std_err);
    qDebug() << "err>" << std_err_str;

    //Maintenance::processFinished , exitCode= 1 , exitStatus= 0
    //out> "[0] Warning: Could not create lock file 'C:/Program Files (x86)/HelloWorld/lockmyApp15021976.lock': アクセスが拒否されました。
    // (0x00000005)
    //"
    //err> "There are currently no updates available.
    //"

    //停止状態に変更
    setState(Maintenance::FINISH);
  }else{
    //停止状態に変更
    setState(Maintenance::STOP);
  }
}
//プロセスがエラー
void Maintenance::processError(QProcess::ProcessError error)
{
  qDebug() << "Maintenance::processError " << error;
  setState(Maintenance::STOP);
}





