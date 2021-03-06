package org.bigbluebutton.command
{
	import mx.utils.ObjectUtil;
	
	import org.bigbluebutton.core.IBigBlueButtonConnection;
	import org.bigbluebutton.core.IUsersService;
	import org.bigbluebutton.core.IVideoConnection;
	import org.bigbluebutton.model.IConferenceParameters;
	import org.bigbluebutton.model.IUserSession;
	import org.bigbluebutton.model.IUserUISession;
	import org.bigbluebutton.view.navigation.pages.PagesENUM;
	import org.osmf.logging.Log;
	
	import robotlegs.bender.bundles.mvcs.Command;
	
	public class ConnectCommand extends Command
	{		
		[Inject]
		public var userSession: IUserSession;
		
		[Inject]
		public var userUISession: IUserUISession;
		
		[Inject]
		public var conferenceParameters: IConferenceParameters;
		
		[Inject]
		public var connection: IBigBlueButtonConnection;
		
		[Inject]
		public var joinVoiceSignal: JoinVoiceSignal;
		
		[Inject]
		public var videoConnection: IVideoConnection;
		
		[Inject]
		public var uri: String;
		
		[Inject]
		public var usersService: IUsersService;
				
		override public function execute():void {
			connection.uri = uri;
			
			connection.successConnected.add(successConnected)
			connection.unsuccessConnected.add(unsuccessConnected)

			connection.connect(conferenceParameters);
		}

		private function successConnected():void {
			Log.getLogger("org.bigbluebutton").info(String(this) + ":successConnected()");
			
			userSession.mainConnection = connection;
			userSession.userId = connection.userId;
			trace("My userId is " + userSession.userId);
			
			userUISession.loading = false;
			userUISession.pushPage(PagesENUM.PARTICIPANTS); 
			
			videoConnection.uri = userSession.config.getConfigFor("VideoConfModule").@uri + "/" + conferenceParameters.room;
			//TODO use proper callbacks
			//TODO see if videoConnection.successConnected is dispatched when it's connected properly
//			videoConnection.successConnected.add(successConnected);
//			videoConnection.unsuccessConnected.add(unsuccessConnected);
			videoConnection.connect();
			userSession.videoConnection = videoConnection;

			usersService.connectUsers(uri);
			usersService.connectListeners(uri);

			joinVoiceSignal.dispatch();
		}
		
		private function unsuccessConnected(reason:String):void {
			Log.getLogger("org.bigbluebutton").info(String(this) + ":unsuccessConnected()");
			
			userUISession.loading = false;
		}
		
	}
}