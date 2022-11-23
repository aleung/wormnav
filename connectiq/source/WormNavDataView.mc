using Toybox.WatchUi;
using Toybox.Activity;
using Toybox.Timer;
using Toybox.Graphics;
using Utils;
using Trace;

class WormNavDataView extends  WatchUi.View {

    private var data = new [4];
    private var activity;
    private var timer;

    // y-axis of row 0/1/2
    private var y0;
    private var y1;
    private var y2;

    const avgChar = StringUtil.utf8ArrayToString([0xC3,0x98]);

    function initialize(activityArg) {
        View.initialize();
        activity = activityArg;
    }

    function onShow() {
        timer = new Timer.Timer();
        timer.start(method(:refresh), 1000, true);      
    }

    function refresh() {
        WatchUi.requestUpdate();
    }

    function onHide() {
        timer.stop();
    }

    function onLayout(dc) {
        var yMargin = System.getDeviceSettings().screenShape == System.SCREEN_SHAPE_ROUND ? 15 : 0;
        var fieldHeight = (dc.getHeight() - yMargin * 2) / 3;
        y0 = yMargin;
        y1 = y0 + fieldHeight;
        y2 = y1 + fieldHeight;
    }

    function onUpdate(dc) {
        System.println("DataView.onUpdate");

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_WHITE);
        dc.clear();

        if (activity.getState() != ACTIVITY_RUNNING) {
            dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
            dc.setPenWidth(15);
            dc.drawCircle(Transform.pixelWidth2, Transform.pixelHeight2, Transform.pixelWidth2);
        }

        // draw lines for 4 data fields
        dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(1);
        dc.drawLine(0, y1, Transform.pixelWidth, y1);
        dc.drawLine(0, y2, Transform.pixelWidth, y2);
        dc.drawLine(Transform.pixelWidth2, y1, Transform.pixelWidth2, y2);

        if(Activity.getActivityInfo()!=null) {
            if( Activity.getActivityInfo().elapsedDistance!= null) {
               data[0] = Activity.getActivityInfo().elapsedDistance/1000;
            }
            if(Activity.getActivityInfo().elapsedTime!=null) {
               data[1] = Activity.getActivityInfo().timerTime;
            }
            if(Activity.getActivityInfo().averageSpeed!=null) {
               data[2] = Activity.getActivityInfo().averageSpeed;
               //data[2] = Utils.convertSpeedToPace(data[2]);
            }
            if(Activity.getActivityInfo().currentHeartRate!=null) {
               data[3] = Activity.getActivityInfo().currentHeartRate;
            }
        }

        var x= Transform.pixelWidth2;
        drawField(dc, "Timer", data[1]!=null? Utils.msToTime(data[1]) : null, x, y0);
        x = Transform.pixelWidth/4;
        drawField(dc, "Distance", data[0]!=null? data[0].format("%.2f") : null, x, y1);
        x = 3*Transform.pixelWidth/4;
        drawField(dc, avgChar + " Pace", data[2]!=null? Utils.convertSpeedToPace(data[2]) : null , x, y1);
        x = Transform.pixelWidth2;
        drawField(dc, "Heart Rate", data[3], x, y2);
    }

    function drawField(dc, label, value, x, y) {
        var offset = 0.5 * Graphics.getFontAscent( Graphics.FONT_MEDIUM );

        if(value==null) {
            value="--";
        }
        if( label == null ) {
            dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
            dc.drawText(x, y + offset, Graphics.FONT_NUMBER_MEDIUM, value, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        } else {
            dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
            dc.drawText(x, y + offset , Graphics.FONT_MEDIUM, label, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
            dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
            dc.drawText(x, y + offset + dc.getFontDescent( Graphics.FONT_MEDIUM )+ 0.5*dc.getFontHeight( Graphics.FONT_NUMBER_MEDIUM ), 
                Graphics.FONT_NUMBER_MEDIUM, value, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        }
        return;
    }
}
