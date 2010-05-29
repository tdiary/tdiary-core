module HelperMethods
	def setup_tdiary
		fixture_conf = File.expand_path("../../fixtures/just_installed/tdiary.conf", File.dirname(__FILE__))
		work_data_dir = File.expand_path("../../../data", File.dirname(__FILE__))
		FileUtils.rm_r work_data_dir if FileTest.exist? work_data_dir

		FileUtils.mkdir work_data_dir
		FileUtils.cp_r fixture_conf, work_data_dir, :verbose => false unless fixture_conf.empty?
	end
end

Spec::Runner.configuration.include(HelperMethods)
