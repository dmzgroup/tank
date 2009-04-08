#ifndef NPSNET_INIT_DOT_H
#define NPSNET_INIT_DOT_H

#include <dmzAppShellExt.h>
#include <QtGui/QWidget>
#include <ui_npsnetInit.h>

namespace dmz {

class NPSNetInit : public QWidget {

   Q_OBJECT

   public:
      NPSNetInit (AppShellInitStruct &init);
      ~NPSNetInit ();

      AppShellInitStruct &init;
      Ui::npsnetSetupForm ui;

   protected slots:
      void on_buttonBox_accepted ();
      void on_buttonBox_rejected ();
      void on_buttonBox_helpRequested ();

   protected:
      virtual void closeEvent (QCloseEvent * event);

      Boolean _start;
};

};

#endif // NPSNET_INIT_DOT_H
