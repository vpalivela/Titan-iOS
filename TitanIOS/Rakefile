BUILD_DIR = File.absolute_path('build')

# Output
XCBUILD_LOG      = BUILD_DIR + "/xcodebuild.log"
XCCOV_LOG        = BUILD_DIR + "/xccoverage.log"
LINT_DESTINATION = BUILD_DIR + "/reports/lint.html"

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

desc "Task for CI Box"
task ci: ['test','lint','cov']

desc "Cleans the build artifacts"
task :clean do
  clean
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
    puts "xcodebuild.log not found in #{BUILD_DIR}".red
    exit 1
  end

  run_cmd("oclint-xcodebuild", "#{OCLINT_BIN_DIR}/oclint-xcodebuild #{XCBUILD_LOG}")

  run_cmd("oclint-json-compilation-database",
          "#{OCLINT_BIN_DIR}/oclint-json-compilation-database \
                -e Pods -- \
                -disable-rule=FeatureEnvy \
                -report-type=html -o #{LINT_DESTINATION} \
                -max-priority-1=9999 \
                -max-priority-2=9999 \
                -max-priority-3=9999 \
                -rc LONG_LINE=120 \
                -rc LONG_VARIABLE_NAME=25")

  puts ""
  run_cmd("lint cleanup", "rm -rf compile_commands.json")
  puts "\nLint Finished, open ./build/reports/lint.html to view results".green
end

desc "Generates code coverage report"
task :cov do
  # run_cmd("cleancov", "XcodeCoverage/cleancov")
  # run_cmd("exportenv.sh", "XcodeCoverage/exportenv.sh")
  run_cmd("cicov", "#{XCODECOVERAGE_DIR}/cicov")
  puts "\nCode Coverage Finished, open ./build/reports/lcov/index.html to view results".green
end

task :show_reports do
  run_cmd("open ./build/reports/lcov/index.html")
  run_cmd("open ./build/reports/lint.html")
  run_cmd("open ./build/reports/tests.html")
end

##############################################################################
# Build Methods
##############################################################################

def xcbuild(build_type = '', xcpretty_args = '')
  unless Dir.exists?(BUILD_DIR)
    Dir.mkdir(BUILD_DIR)
    Dir.mkdir(BUILD_DIR+"/reports")
  end

  run_cmd("xcodebuild " + build_type,
          "xcodebuild \
            -workspace #{WORKSPACE} \
            -scheme #{SCHEME} \
            -sdk iphonesimulator#{SDK_BUILD_VERSION} \
            -configuration #{BUILD_CONFIGURATION} \
            #{build_type} 2>&1 | \
            tee #{XCBUILD_LOG} 2>&1 | \
            xcpretty -c #{xcpretty_args}; \
            exit ${PIPESTATUS[0]}")
end

def clean
  xcbuild('clean')
end;

def build
  xcbuild('build')
end

def test
  close_simulator
  xcbuild("test", "-r html")
  close_simulator
end

def close_simulator
  log_info("Closing","iPhone Simulator")
    `killall -m -KILL \"iPhone Simulator\"`
    puts ""
end

##############################################################################
# Private Methods
##############################################################################

private

def run_cmd(desc = nil, cmd)
  desc = cmd if desc.nil?
  log_info("Running", desc)
  Dir.mkdir(BUILD_DIR) unless Dir.exists?(BUILD_DIR)
  unless system("#{cmd}")
    log_error(desc)
    exit 1
  end
end

def log_info(action, description)
  puts "\u25B8".encode('utf-8').yellow + " #{action}".bold + " #{description}"
end

def log_error(description)
  puts "\u25B8".encode('utf-8').red + " FAILED".bold.red + " #{description}".red
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
