using Toybox.Activity;
using Toybox.ActivityRecording;
using Toybox.Lang;
using Toybox.Attention;


enum {
    ACTIVITY_NOT_START,
    ACTIVITY_RUNNING,
    ACTIVITY_PAUSE
}    

class WormNavActivity {

    // public, for LapView to read
    var lapTime = 0;
    var lapCounter = 0;

    private var state = ACTIVITY_NOT_START;
    private var recordSession;

    // lap
    private var elapsedLapTimeP = 0;
    private var elapsedLapDistanceP = 0.0;
    private var elapsedLapTime = 0;
    private var elapsedLapDistance = 0.0;
    private var lapInitDistance = 0.0;
    private var lapInitTime = 0;  
    private var autolapDistance = 1000;

    function initialize() {
        if (Application.getApp().getProperty("autolapDistance") != null) {
            autolapDistance = Application.getApp().getProperty("autolapDistance");
        }
    }

    function setAutoLapDistance(distance) {
        autolapDistance = distance;
        Application.getApp().setProperty("autolapDistance", autolapDistance);
        if ( getState() != ACTIVITY_NOT_START && autolapDistance > 0 ) {
            manualLap();
        }
    }

    function getAutolapDistanceStr() {
        if (autolapDistance == 0) {
            return "off";
        } else if(autolapDistance < 1000) {
            return autolapDistance + "m";
        } else {
            return autolapDistance/1000 + "km";
        }
    }

    function manualLap() {
        var elapsedDistance = Activity.getActivityInfo().elapsedDistance;
        var elapsedTime = Activity.getActivityInfo().elapsedTime;
        if ( elapsedTime != null && elapsedTime > 0 && elapsedDistance != null  && elapsedDistance > 0) {
            lapInitTime = elapsedTime;
            lapInitDistance = elapsedDistance;
            lapCounter++;
            recordSession.addLap();
        }
    }

    function isAutolap() {
        var isLap = false;

        if (getState() == ACTIVITY_RUNNING && autolapDistance > 0) {
            var elapsedDistance = Activity.getActivityInfo().elapsedDistance;
            var elapsedTime = Activity.getActivityInfo().elapsedTime;
            if ( elapsedTime != null && elapsedTime > 0 && elapsedDistance != null  && elapsedDistance > 0) {
                elapsedLapTime = elapsedTime - lapInitTime;
                elapsedLapDistance = elapsedDistance - lapInitDistance;
                System.println("elapsedDistance:" + elapsedDistance + ", elapsedLapDistance:" + elapsedLapDistance);

                if (elapsedLapDistance > autolapDistance) {
                    lapTime = elapsedLapTimeP + 
                      (autolapDistance - elapsedLapDistanceP)/(elapsedDistance - elapsedLapDistanceP)*(elapsedTime - elapsedLapTimeP);
                    lapInitTime = lapInitTime + lapTime;
                    lapInitDistance = lapInitDistance + autolapDistance;
                    lapCounter++;
                    isLap = true;
                    recordSession.addLap();
                }
                elapsedLapTimeP = elapsedLapTime;
                elapsedLapDistanceP = elapsedLapDistance;
            }
        }

        return isLap;
    }

    function getState() {
        System.println("Current state: " + state);
        return state;
    }

    function toggleStart() {
        switch (state) {
            case ACTIVITY_NOT_START:
                newState(ACTIVITY_RUNNING);
                // TODO: get activity type from properties
                recordSession = ActivityRecording.createSession({:name=>"RUN", :sport=>ActivityRecording.SPORT_RUNNING});
                recordSession.start();
                break;
            case ACTIVITY_RUNNING:
                newState(ACTIVITY_PAUSE);
                recordSession.stop();
                break;
            case ACTIVITY_PAUSE:
                newState(ACTIVITY_RUNNING);
                recordSession.start();
                break;
            default:
                error("[Bug] Activity.toggleStart() in unknown state: " + state);
        }
        vibrate();
    }

    function exit(saveSession) {
        switch (state) {
            case ACTIVITY_NOT_START:
                break;
            case ACTIVITY_PAUSE:
                if (saveSession) {
                    recordSession.save();
                } else {
                    recordSession.discard();
                }
                break;
            default:
                error("[Bug] Activity.exit() in invalid state: " + state);
        }
        System.exit();
    }

    private function vibrate() {
        if (Attention has :vibrate) {
            Attention.vibrate( [new Attention.VibeProfile(50, 1000)] );
        }        
    }

    private function newState(s) {
        System.println("State: " + state + "->" + s);
        state = s;
    }

    private function error(msg) {
        try {
          throw new Lang.Exception(msg);
        } catch(e) {
          e.printStackTrace();
        }
    }
}
