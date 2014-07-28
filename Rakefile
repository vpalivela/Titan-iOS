require 'shellwords'

BUILD_DIR   = File.expand_path('build')
REPORTS_DIR = BUILD_DIR + "/reports"

# Output
XCBUILD_LOG      = BUILD_DIR + "/xcodebuild.log"
XCCOV_LOG        = BUILD_DIR + "/xccoverage.log"
LINT_DESTINATION = REPORTS_DIR + "/lint.html"

# Libraries
OCLINT_BIN_DIR    = ENV["OCLINT_BIN_DIR"] || "ThirdParty/oclint-0.9.dev.648e9af/bin"
XCODECOVERAGE_DIR = ENV["XCODECOVERAGE_DIR"] || "XcodeCoverage"

# Build
WORKSPACE           = 'TitanIOS.xcworkspace'
SCHEME              = 'TitanIOS'
SDK_BUILD_VERSION   = ENV["SDK_BUILD_VERSION"] || ""
BUILD_CONFIGURATION = ENV["BUILD_CONFIGURATION"] || "Debug"

##############################################################################
# Standard tasks
##############################################################################

task :default do
  system "rake --tasks"
end

desc "All in one task to build, test, generate report and open them."
task :go => ['test', 'lint', 'cov', 'reports']

desc "Task for CI Box"
task :ci => ['test','lint','cov']

desc "Cleans the build artifacts"
task :clean do
  clean
  run_cmd("rm -rf ~/Library/Developer/Xcode/DerivedData/#{SCHEME}-*", 'DerivedData Cleanup')
  run_cmd('rm -rf build')
end

desc "Builds the application"
task :build => :clean do
  build
end

desc "Tests the application"
task :test => :clean do
  test
end

desc "Runs lint on the application"
task :lint do
  log_info("Starting","lint")

  if !File.exists?(XCBUILD_LOG)
    log_error("xcodebuild.log not found in #{BUILD_DIR}")
  end

  run_cmd("#{OCLINT_BIN_DIR}/oclint-xcodebuild #{XCBUILD_LOG}", "oclint-xcodebuild")

  run_cmd("#{OCLINT_BIN_DIR}/oclint-json-compilation-database \
                -e Pods -- \
                -disable-rule=FeatureEnvy \
                -report-type=html -o #{LINT_DESTINATION} \
                -max-priority-1=9999 \
                -max-priority-2=9999 \
                -max-priority-3=9999 \
                -rc LONG_LINE=120 \
                -rc LONG_VARIABLE_NAME=25",
          "oclint-json-compilation-database")

  run_cmd("rm -rf compile_commands.json", "lint cleanup")

  puts "\nLint Finished, open #{REPORTS_DIR}/lint.html to view results".green
end

desc "Generates code coverage report"
task :cov do
  run_cmd("#{XCODECOVERAGE_DIR}/cicov", "cicov")
  run_cmd("ln -s #{REPORTS_DIR}/lcov/index.html #{REPORTS_DIR}/codecoverage.html", "Code Coverage Report")
  puts "\nCode Coverage Finished, open #{REPORTS_DIR}/codecoverage.html to view results".green
end

task :reports do
  run_cmd("open #{REPORTS_DIR}")
end

##############################################################################
# Build Methods
##############################################################################

def xcbuild(build_type = '', xcpretty_args = '')
  unless File.exists?(BUILD_DIR)
    Dir.mkdir(BUILD_DIR)
    Dir.mkdir(REPORTS_DIR)
  end

  run_cmd("xcodebuild \
            -workspace #{WORKSPACE} \
            -scheme #{SCHEME} \
            -sdk iphonesimulator#{SDK_BUILD_VERSION} \
            -configuration #{BUILD_CONFIGURATION} \
            #{build_type} 2>&1 | \
            tee #{XCBUILD_LOG} 2>&1 | \
            xcpretty -c --no-utf #{xcpretty_args}; \
            exit ${PIPESTATUS[0]}",
          "xcodebuild " + build_type)
end

def clean
  xcbuild('clean')
end;

def build
  xcbuild('clean build')
end

def test
  close_simulator
  xcbuild("clean test", "--test -r html")
  close_simulator
end

def close_simulator
  begin
    log_info("Closing","iPhone Simulator")
    sh `killall -m -KILL \"iPhone Simulator\"`
  rescue
    nil
  end
end

##############################################################################
# Private Methods
##############################################################################

private

def run_cmd( cmd, desc = nil)
  desc ||= cmd
  log_info("Running", desc)
  Dir.mkdir(BUILD_DIR) unless File.exists?(BUILD_DIR)
  unless system("#{cmd}")
    log_error(desc)
  end
end

def log_info(action, description)
  puts ">".yellow + " #{action}".bold + " #{description}"
end

def log_error(description)
  puts "[!] FAILED #{description}".red
  exit 1
end

class String
  def colorize(color_code)
    "\e[#{color_code}m#{self}\e[0m"
  end

  def red
    colorize(31)
  end

  def green
    colorize(32)
  end

  def yellow
    colorize(33)
  end

  def bold
    "\e[1m#{self}\e[22m"
  end
end
