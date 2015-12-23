module app;

import dlangui;
import core.thread;
import dmusic.audioCore,
       dmusic.type;

mixin APP_ENTRY_POINT;
import derelict.sndfile.sndfile;

extern (C) int UIAppMain(string[] args) {
  Window window = Platform.instance.createWindow("DMUSIC", null, WindowFlag.Modal, 400, 200);

  window.mainWidget = parseML(q{
      VerticalLayout {
        margins: 10
        padding: 10
        backgroundColor: "#C0E0E070"
        
        TextWidget { text: "DMUSIC"; textColor: "red"; fontSize: 150%; fontWeight: 800; fontFace: "Arial" }
        
        TableLayout {
          colCount: 2
          TextWidget { text: "FileName:" } 
          EditLine { text: "please input filename"; id: editFilename }

          TextWidget { text: "Title" }
          EditLine { id: textTitle; }

          TextWidget { text: "Aritist" }
          EditLine { id: textArtist }

          TextWidget { text: "Alubm" }
          EditLine { id: textAlubum }

        }

        HorizontalLayout {
          Button { id: btnPlay; text: "Play" }
          Button { id: btnResume; text: "Resume" }
          Button { id: btnStop; text: "Stop" }
          Button { id: btnChange; text: "Change" }
          Button { id: btnExit; text: "exit" }
        }
      }
    });

        window.mainWidget.childById!EditLine("textTitle").focusable(false);
        window.mainWidget.childById!EditLine("textArtist").focusable(false);
        window.mainWidget.childById!EditLine("textAlubum").focusable(false);
  string fileName;
  auto play = (){
    fileName = window.mainWidget.childById!EditLine("editFilename").text.to!string.strip;
    new Thread(() => musicPlay(fileName)).start;
    new Thread((){
        import std.stdio;
        Thread.sleep(dur!"msecs"(100));
        string[string] _info = getMetaInfo.info;
        window.mainWidget.childById!EditLine("textTitle").text(_info["title"].to!dstring);
        window.mainWidget.childById!EditLine("textArtist").text(_info["artist"].to!dstring);
        window.mainWidget.childById!EditLine("textAlubum").text(_info["album"].to!dstring);

        }).start;
  };

  window.mainWidget.childById!Button("btnStop").enabled = false;
  window.mainWidget.childById!Button("btnResume").enabled = false;

  window.mainWidget.childById!Button("btnPlay").click = delegate(Widget w) {  
    play();

    window.mainWidget.childById!Button("btnPlay").enabled = false;
    window.mainWidget.childById!Button("btnStop").enabled = true;
    return true;
  };

  window.mainWidget.childById!Button("btnResume").click = delegate(Widget w) {
    setResume(true);
    play();

    window.mainWidget.childById!Button("btnPlay").enabled = false;
    window.mainWidget.childById!Button("btnStop").enabled = true;
    return true;
  };

  window.mainWidget.childById!Button("btnStop").click = delegate(Widget w) {  
    setPlaying(false);

    window.mainWidget.childById!Button("btnStop").enabled = false;
    window.mainWidget.childById!Button("btnPlay").enabled = true;
    window.mainWidget.childById!Button("btnResume").enabled = true;
    return true;
  };

  window.mainWidget.childById!Button("btnChange").click = delegate(Widget w) {  
    import dlangui.dialogs.filedlg,
           dlangui.dialogs.dialog;

    UIString caption = "select file"d;
    uint flag = DialogFlag.Modal;
    string file;
    auto dialog = new FileDialog(caption, window, null, flag);
    dialog.dialogResult = delegate(Dialog dialog, const Action result){
      auto strings = result.stringParam.split("/");
      window.mainWidget.childById!EditLine("editFilename").text = strings[$-1].to!dstring;
      play();
    };
    dialog.show;

    window.mainWidget.childById!Button("btnPlay").enabled = false;
    window.mainWidget.childById!Button("btnStop").enabled = true;
    return true;
  };

  window.mainWidget.childById!Button("btnExit").click = delegate(Widget w) {
    setPlaying(false);
    window.close();
    return true;
  };

  window.show();

  return Platform.instance.enterMessageLoop();
}
