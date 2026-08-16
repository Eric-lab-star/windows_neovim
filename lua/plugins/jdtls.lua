-- eclipse.jdt.ls is not a plain `jdtls` executable -- it is a JVM application
-- launched through an equinox jar, with one server per project root and its own
-- `-data` workspace. nvim-jdtls does that bookkeeping; ftplugin/java.lua holds
-- the actual command line and calls start_or_attach().
--
-- That is also why 'jdtls' is not in the servers table in lsp.lua: enabling it
-- there would start a second, differently-configured client for the same buffer.
--
-- The distribution itself is already unpacked in ~/AppData/Local/nvim/jdtls
-- (config_win + plugins/org.eclipse.equinox.launcher_*.jar), and java 26 is on
-- PATH, comfortably past the JDK 21 the server needs.
return {
	'mfussenegger/nvim-jdtls',
	ft = 'java',
}
