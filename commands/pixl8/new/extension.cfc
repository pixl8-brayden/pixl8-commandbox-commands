/**
 * Scaffolds a new private Pixl8 Extension
 *
 **/
component {


	/**
	 * @title.hint        Extension name
	 * @slug.hint         Extension slug (without preside-ext-)
	 * @repoUrl.hint      Repository URL (without .git)
	 * @slackChannel.hint Slack channel for build notifications, e.g. builds
	 * @directory.hint    Directory in which extension will be scaffolded
	 *
	 **/
	function run(
		  required string name
		, required string slug
		, required string repoUrl
		, required string slackChannel
		,          string directory = shell.pwd()
	) {
		if ( !_validSlug( arguments.slug ) ) {
			return _printError( "Invalid slug. Extension slug must contain alphanumerics, underscores and hyphens only." );
		}
		if ( !DirectoryExists( arguments.directory ) ) {
			return _printError( "Directory, [#arguments.directory#], does not exist" );
		}
		var requireStatic = "";
		do {
			requireStatic = shell.ask( "Will your extension require CSS/JS? (Y/N): " );
		} while( requireStatic != "Y" && requireStatic != "N" );

		arguments.slug = arguments.slug.reReplace( "^preside\-ext\-", "" );

		_unpackSkeleton( arguments.directory );
		_replacePlaceholdersWithArgs( argumentCollection=arguments );

		if ( !requireStatic == "Y" ) {
			DirectoryDelete( arguments.directory & "/assets", true );
		}

		print.line();
		print.greenLine( "************************************************" );
		print.greenLine( "Your extension has been successfully scaffolded." );
		print.greenLine( "************************************************" );
		print.line();

		return;
	}

// PRIVATE HELPERS
	private boolean function _validSlug( required string slug ) {
		return ReFindNoCase( "^[a-z0-9-_]+$", arguments.slug );
	}

	private void function _printError( errorMessage ) {
		print.line();
		print.redLine( arguments.errorMessage );
		print.line();
	}

	private void function _unpackSkeleton( required string directory ) {
		var source = GetDirectoryFromPath( GetCurrentTemplatePath() ) & "/../../../resources/extension";

		DirectoryCopy( source, arguments.directory, true );

		FileSetAccessMode( arguments.directory & "/runtests.sh", "755" );
	}

	private void function _replacePlaceholdersWithArgs(
		  required string name
		, required string slug
		, required string repoUrl
		, required string slackChannel
		, required string directory
	) {
		var filePaths = [
			  arguments.directory & "/manifest.json"
			, arguments.directory & "/box.json"
			, arguments.directory & "/.gitlab-ci.yml"
			, arguments.directory & "/README.md"
			, arguments.directory & "/assets/package.json"
			, arguments.directory & "/tests/Application.cfc"
			, arguments.directory & "/runtests.sh"
			, arguments.directory & "/server-tests.json"
		];

		var testPort = Int( RandRange(4000, 9999 ) );

		for( var filePath in filePaths ) {
			var fileContent = FileRead( filePath );

			fileContent = ReplaceNoCase( fileContent, "EXTENSIONSLUG", arguments.slug        , "all" );
			fileContent = ReplaceNoCase( fileContent, "EXTENSIONNAME", arguments.name        , "all" );
			fileContent = ReplaceNoCase( fileContent, "EXTENSIONURL" , arguments.repoUrl     , "all" );
			fileContent = ReplaceNoCase( fileContent, "BUILDCHANNEL" , arguments.slackChannel, "all" );
			fileContent = ReplaceNoCase( fileContent, "TESTPORT"     , testPort              , "all" );

			FileWrite( filePath, fileContent );
		}
	}

}