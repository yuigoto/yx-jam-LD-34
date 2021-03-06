package br.com.sixsided.spindulum;

// Importing packages
import br.com.sixsided.spindulum.entities.Button;
import br.com.sixsided.spindulum.screens.ScreenGame;
import br.com.sixsided.spindulum.screens.ScreenOver;
import br.com.sixsided.spindulum.screens.ScreenTitle;
import br.com.sixsided.spindulum.screens.ScreenWins;
import motion.Actuate;
import openfl.Assets;
import openfl.display.MovieClip;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.KeyboardEvent;
import openfl.events.MouseEvent;
import openfl.events.TouchEvent;
import openfl.geom.Point;
import openfl.Lib;
import openfl.media.Sound;
import openfl.media.SoundChannel;
import openfl.media.SoundTransform;
import openfl.text.Font;

/**
 * SIXSIDED :: [SX] Spindulum 
 * ============================================================
 * 
 * This is a simple and abstract action game, made for LD#34.
 * 
 * Themes for this Ludum Dare are:
 * - Two button controls;
 * - Growing;
 * 
 * Controls:
 * - Left;
 * - Right;
 * 
 * You're a tiny dot attached to a collector.
 * 
 * Collect the orange dots, while avoiding the blue dots, to make yourself 
 * grow in size.
 * 
 * You've got to grow at the minimum size of the gray area before you're able 
 * to press "LEFT" and "RIGHT" at the same time, so you can explode and advance 
 * to the next level.
 * 
 * Every level, the gray area increases and the average speed for the dots also 
 * increase.
 * 
 * Can you make it to the 10th level?
 * 
 * @author     Fabio Yuiti Goto
 * @link       http://sixsided.com.br
 * @version    1.2.0
 * @copy       ®2015 SIXSIDED Developments
 */
class Main extends Sprite 
{
    /**
     * Handles input controls.
     */
    public static var inputs:Array<Bool>;
    
    /**
     * Stores the main stage width.
     * 
     * This is needed because, since some objects are generated outside of 
     * the screen, these objects change the main stage width.
     */
    public static var gameScreenW:Int = 640;
    
    /**
     * Stores the main stage height.
     * 
     * This is needed because, since some objects are generated outside of 
     * the screen, these objects change the main stage height.
     */
    public static var gameScreenH:Int = 640;
    
    /**
     * Font to be used for the game.
     */
    public static var gameFont:Font = null;
    
    /**
     * Indicator for the current level of the game.
     */
    public static var levelCurrent:Int = 0;
    
    /**
     * Indicates the best level the player could get through.
     */
    public static var levelRecord:Int = 0;
    
    /**
     * Current screen.
     */
    public static var currentScreen:Int = 0;
    
    /**
     * Screen objects handle.
     */
    public static var screenHandle:Dynamic;
    
    /**
     * Handle for the title voice.
     */
    public static var soundTitle:Sound;
    
    /**
     * Handle for the ready voice.
     */
    public static var soundReady:Sound;
    
    /**
     * Handle for the go voice.
     */
    public static var soundGo:Sound;
    
    /**
     * Handle for the next level.
     */
    public static var soundNext:Sound;
    
    /**
     * Handle for the game over.
     */
    public static var soundGameOver:Sound;
    
    /**
     * Handle for the thank you.
     */
    public static var soundThanks:Sound;
    
    /**
     * Song handler.
     */
    public static var song:Sound;
    
    /**
     * Sound channel for music.
     */
    public static var channel:SoundChannel;
    
    /**
     * Sfx Orange handler.
     */
    public static var sfxOrange:Sound;
    
    /**
     * Sfx Blue handler.
     */
    public static var sfxBlue:Sound;
    
    /**
     * Android only, L button.
     */
    public static var buttonL:Button;
    
    /**
     * Android only, R button.
     */
    public static var buttonR:Button;
    
    /**
     * Main constructor.
     */
	public function new() 
	{
        // Calling super constructor
		super();
        
        // Initialize input array
        inputs = new Array();
        
        // Defines the game font
        #if android
            gameFont = new Font( "fonts/oswald-light.ttf" );
        #else
            gameFont = Assets.getFont( "fonts/oswald-light.ttf" );
        #end
        
        // Initializes all sounds
        soundTitle = Assets.getSound( "sound/sound-title.wav" );
        soundReady = Assets.getSound( "sound/sound-ready.wav" );
        soundGo = Assets.getSound( "sound/sound-go.wav" );
        soundNext = Assets.getSound( "sound/sound-next.wav" );
        soundGameOver = Assets.getSound( "sound/sound-gameover.wav" );
        soundThanks = Assets.getSound( "sound/sound-thank.wav" );
        
        // Loading SFX
        sfxOrange = Assets.getSound( "sound/fx-hit-orange.wav" );
        sfxBlue = Assets.getSound( "sound/fx-hit-blue.wav" );
        
        // Loading song
        song = Assets.getSound( "sound/song.wav" );
        
        // Initializing sound channel
        channel = new SoundChannel();
        
        // Playing sound
        #if ( cpp || neko )
            channel = song.play( 0, 0, new SoundTransform( 1 ) );
        #else
            channel = song.play( 0, 0, new SoundTransform( 1 ) );
        #end
        
        // Sound loop check
        channel.addEventListener( Event.SOUND_COMPLETE, loopSong );
        
        // If stage is set
        if ( null != stage ) {
            // Executes main event
            init( null );
        } else {
            // If not, adds main event as an event listener
            addEventListener( Event.ADDED_TO_STAGE, init );
        }
        
        #if ( android )
            // If android, draws a background, to determine width of this object
            graphics.beginFill( 0x000000, 0 );
            graphics.drawRect( 0, 0, gameScreenW, gameScreenH );
            graphics.endFill();
            
            // Resizes the screen to the current window size
            this.width = stage.stageHeight;
            this.height = stage.stageHeight;
            
            // Centering the game window
            this.x = ( stage.stageWidth / 2 ) - ( stage.stageHeight / 2 );
            this.y = ( stage.stageHeight / 2 ) - ( stage.stageHeight / 2 );
            
            trace( stage.stageWidth );
            
            // Defining button width
            var buttonW:Float = ( ( stage.stageWidth ) - ( stage.stageHeight ) ) / 2;
            var buttonH:Float = stage.stageHeight;
            
            // Initialize buttons
            buttonL = new Button( "<" );
            buttonR = new Button( ">" );
            
            // Adds to stage before resizing
            stage.addChild( buttonL );
            stage.addChild( buttonR );
            
            // Resizing
            cast( buttonL, Button ).width = buttonW;
            cast( buttonL, Button ).height = buttonH;
            cast( buttonR, Button ).width = buttonW;
            cast( buttonR, Button ).height = buttonH;
            
            // Defining keycodes to emulate L/R strokes
            cast( buttonL, Button ).keycode = 37;
            cast( buttonR, Button ).keycode = 39;
            
            // Positioning L
            buttonL.x = 0;
            buttonL.y = 0;
            
            // Positioning R
            buttonR.x = stage.stageWidth - buttonW;
            buttonR.y = 0;
            
            // Add event listeners
            buttonL.addEventListener( TouchEvent.TOUCH_BEGIN, mouseDown );
            buttonL.addEventListener( TouchEvent.TOUCH_END, mouseUp );
            
            buttonR.addEventListener( TouchEvent.TOUCH_BEGIN, mouseDown );
            buttonR.addEventListener( TouchEvent.TOUCH_END, mouseUp );
        #else
            // Adds the key up/down events
            stage.addEventListener( KeyboardEvent.KEY_DOWN, keysDn );
            stage.addEventListener( KeyboardEvent.KEY_UP, keysUp );
        #end
        
        #if debug
            // Add FPS Monitor
            var FPSMon:MemFPSMini = new MemFPSMini();
            addChild( FPSMon );
        #end
	}
    
    /**
     * Main event.
     * 
     * @param e Event
     */
    public function init( e:Event = null ):Void 
    {
        // Remove this event listener
        removeEventListener( Event.ADDED_TO_STAGE, init );
        
        // Checks the screen
        switch ( currentScreen ) {
            case 1: 
                // The game
                screenHandle = new ScreenGame();
                screenHandle.isFinished = false;
                addChild( screenHandle );
                
                // Adds the game screen event handler
                addEventListener( Event.ENTER_FRAME, screenGameEvents );
            case 2: 
                // The game win screen
                screenHandle = new ScreenWins();
                screenHandle.isFinished = false;
                #if flash
                    screenHandle.alpha = 0;
                #else
                    cast( screenHandle, ScreenWins ).alpha = 0;
                #end
                addChild( screenHandle );
                
                // Tweening the screen
                #if flash
                    Actuate.tween(
                        screenHandle, 
                        1, 
                        {
                            alpha: 1
                        }
                    ).onComplete( setScreenAlpha );
                #else
                    Actuate.tween(
                        cast( screenHandle, ScreenWins ), 
                        1, 
                        {
                            alpha: 1
                        }
                    ).onComplete( setScreenAlpha );
                #end
                
                // Adds the game screen event handler
                addEventListener( Event.ENTER_FRAME, screenWinsEvents );
            case 3: 
                // The game over screen
                screenHandle = new ScreenOver();
                screenHandle.isFinished = false;
                #if flash
                    screenHandle.alpha = 0;
                #else
                    cast( screenHandle, ScreenOver ).alpha = 0;
                #end
                addChild( screenHandle );
                
                // Tweening the screen
                #if flash
                    Actuate.tween(
                        screenHandle, 
                        1, 
                        {
                            alpha: 1
                        }
                    ).onComplete( setScreenAlpha );
                #else
                    Actuate.tween(
                        cast( screenHandle, ScreenOver ), 
                        1, 
                        {
                            alpha: 1
                        }
                    ).onComplete( setScreenAlpha );
                #end
                
                // Adds the game screen event handler
                addEventListener( Event.ENTER_FRAME, screenOverEvents );
            default:
                // The title screen
                screenHandle = new ScreenTitle();
                screenHandle.isFinished = false;
                #if flash
                    screenHandle.alpha = 0;
                #else
                    cast( screenHandle, ScreenTitle ).alpha = 0;
                #end
                addChild( screenHandle );
                
                // Tweening the screen
                #if flash
                    Actuate.tween(
                        screenHandle, 
                        1, 
                        {
                            alpha: 1
                        }
                    ).onComplete( setScreenAlpha );
                #else
                    Actuate.tween(
                        cast( screenHandle, ScreenTitle ), 
                        1, 
                        {
                            alpha: 1
                        }
                    ).onComplete( setScreenAlpha );
                #end
                
                // Adds the first screen event handler
                addEventListener( Event.ENTER_FRAME, screenInitEvents );
        }
        
        // Swap z-index
        setChildIndex( screenHandle, 0 );
    }
    
    /**
     * Key pressed event.
     * 
     * @param e
     *      KeyboardEvent handle
     */
    public function keysDn( e:KeyboardEvent ):Void 
    {
        // If this key isn't pressed
        if ( !inputs[e.keyCode] ) {
            // Define as pressed
            inputs[e.keyCode] = true;
        }
    }
    
    /**
     * Key lifted event.
     * 
     * @param e
     *      KeyboardEvent handle
     */
    public function keysUp( e:KeyboardEvent ):Void 
    {
        // If this key is pressed
        if ( inputs[e.keyCode] ) {
            // Define as unpressed
            inputs[e.keyCode] = false;
        }
    }
    
    /**
     * 
     * @param e 
     *      MouseEvent handle
     */
    public function mouseDown( e:TouchEvent ):Void 
    {
        // If this key is pressed
        if ( !inputs[e.target.parent.keycode] ) {
            trace( "PRESSED" );
            // Define as unpressed
            inputs[e.target.parent.keycode] = true;
        }
    }
    
    /**
     * 
     * @param e 
     *      MouseEvent handle
     */
    public function mouseUp( e:TouchEvent ):Void 
    {
        trace( e.target );
        // If this key is pressed
        if ( inputs[e.target.parent.keycode] ) {
            trace( "LIFTED!" );
            // Define as unpressed
            inputs[e.target.parent.keycode] = false;
        }
    }
    
    /**
     * Loops the song.
     * 
     * @param e
     *      Event handle
     */
    public function loopSong( e:Event ):Void 
    {
        // Remove event listener
        channel.removeEventListener( Event.SOUND_COMPLETE, loopSong );
        // Playing the song
        #if ( cpp || neko )
            channel = song.play( 24, 0, new SoundTransform( 1 ) );
        #else
            channel = song.play( 24000, 0, new SoundTransform( 1 ) );
        #end
        // Add event listener
        channel.addEventListener( Event.SOUND_COMPLETE, loopSong );
    }
    
    /**
     * Handles the title screen updates.
     * 
     * @param e
     *      Event handle
     */
    public function screenInitEvents( e:Event ):Void 
    {
        #if debug
            trace( this.width );
        #end
        
        // If, by chance, the screen is finished
        if ( screenHandle.isFinished ) {
            // Removes the screen handle and set it to null
            removeChild( screenHandle );
            screenHandle = null;
            
            // Remove this event handler
            removeEventListener( Event.ENTER_FRAME, screenInitEvents );
            
            // Sets the game current level
            levelCurrent = 0;
            
            // Sets the current screen as game
            currentScreen = 1;
            
            // Reboots
            init();
        }
    }
    
    /**
     * Handles the game screen updates.
     * 
     * @param e
     *      Event handle
     */
    public function screenGameEvents( e:Event ):Void 
    {
        #if debug
            trace( this.width );
        #end
        
        // Checks game status
        if ( 
            screenHandle.playerIsDead 
            && screenHandle.gameIsOver 
            && screenHandle.isFinished 
        ) {
            // Removes the screen handle and set it to null
            removeChild( screenHandle );
            screenHandle = null;
            
            // Remove this event handler
            removeEventListener( Event.ENTER_FRAME, screenGameEvents );
            
            // Compares best level
            if ( levelRecord < levelCurrent ) levelRecord = levelCurrent;
            
            // Sets current screen to game over
            currentScreen = 3;
            
            // Reboots
            init();
        } else if (
            screenHandle.roundHasEnded 
            && screenHandle.isFinished 
            && levelCurrent < 9
        ) {
            // Removes the screen handle and set it to null
            removeChild( screenHandle );
            screenHandle = null;
            
            // Remove this event handler
            removeEventListener( Event.ENTER_FRAME, screenGameEvents );
            
            // Compares best level
            if ( levelRecord < levelCurrent ) levelRecord = levelCurrent;
            
            // Sets the level to the next one
            levelCurrent += 1;
            
            // Maintains current screen
            currentScreen = 1;
            
            // Reboots
            init();
        }
    }
    
    /**
     * Handles the game wins screen updates.
     * 
     * @param e
     *      Event handle
     */
    public function screenWinsEvents( e:Event ):Void 
    {
        // If, by chance, the screen is finished
        if ( screenHandle.isFinished ) {
            // Removes the screen handle and set it to null
            removeChild( screenHandle );
            screenHandle = null;
            
            // Remove this event handler
            removeEventListener( Event.ENTER_FRAME, screenWinsEvents );
            
            // Sets the game current level
            levelCurrent = 0;
            
            // Sets the current screen as title
            currentScreen = 0;
            
            // Reboots
            init();
        }
    }
    
    /**
     * Handles the game over screen updates.
     * 
     * @param e
     *      Event handle
     */
    public function screenOverEvents( e:Event ):Void 
    {
        // If, by chance, the screen is finished
        if ( screenHandle.isFinished ) {
            // Removes the screen handle and set it to null
            removeChild( screenHandle );
            screenHandle = null;
            
            // Remove this event handler
            removeEventListener( Event.ENTER_FRAME, screenOverEvents );
            
            // Sets the game current level
            levelCurrent = 0;
            
            // Sets the current screen as title
            currentScreen = 0;
            
            // Reboots
            init();
        }
    }
    
    /**
     * Sets the screen handle alpha.
     */
    public function setScreenAlpha():Void 
    {
        screenHandle.alpha = 1;
    }
    
    /**
     * Finds the second vertex in a line, given the angle, distance and the 
     * coordinates of the first point in the cartesian plane.
     * 
     * @param angle 
     *      The angle/rotation value, in degrees from 0 ~ 359
     * @param distance 
     *      The distance/length of the hypotenuse (to find the vertex)
     * @param posX 
     *      X position of the first point
     * @param posY 
     *      Y position of the first point
     * @return 
     *      A Point object, with the coordinates of the vertex's end
     */
    public static function vertexFinder(
        angle:Float, 
        distance:Float, 
        posX:Float, 
        posY:Float 
    ):Point {
        // Finding radian
        var radian:Float = Math.PI / 180;
        
        // Returning point
        return new Point(
            posX + ( distance * Math.cos( angle * radian ) ), 
            posY + ( distance * Math.sin( angle * radian ) )
        );
    }
    
    /**
     * Returns a pseudo-random number between min and max.
     * 
     * @param min 
     *      Minimum value in the range (Default: 0)
     * @param max
     *      Maximum value in the range (Default: 2147483647)
     * @return 
     *      A random integer
     */
    public static function randomNumber( min:Int = 0, max:Int = 2147483647 ):Int 
    {
        return Math.floor( Math.random() * ( max - min + 1 ) + min );
    }
    
    /**
     * Gets the angle of a line between two points.
     * 
     * @param x1
     *      X-coordinate of the origin point
     * @param y1
     *      Y-coordinate of the origin point
     * @param x2
     *      X-coordinate of the destination point
     * @param y2
     *      Y-coordinate of the destination point
     * @return
     *      A float number, with the rotation
     */
    public static function pointsToAngles(
        x1:Float, 
        y1:Float, 
        x2:Float, 
        y2:Float 
    ):Float {
        // Calculating variables
        var val1 = x2 - x1;
        var val2 = y2 - y1;
                
        // Returning the value
        return Math.atan2( val2, val1 ) * ( 180 / Math.PI );
    }
}