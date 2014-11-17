# Directories
BUILD_DIR    = File.expand_path('build')
REPORTS_DIR  = BUILD_DIR + "/reports-" + Time.now.strftime("%d-%m-%Y")

# Output
XCBUILD_LOG      = BUILD_DIR + "/xcodebuild.log"
XCCOV_LOG        = BUILD_DIR + "/xccoverage.log"
LINT_DESTINATION = REPORTS_DIR + "/lint.html"

# Libraries
OCLINT_BIN_DIR     = ENV["OCLINT_BIN_DIR"] || "ThirdParty/oclint-0.9.dev.648e9af/bin"
XCODECOVERAGE_DIR  = ENV["XCODECOVERAGE_DIR"] || "XcodeCoverage"
XCPRETTY_AVALIABLE = Gem::Specification::find_all_by_name('xcpretty').any?

# Build
WORKSPACE           = 'TitanIOS.xcworkspace'
SCHEME              = 'TitanIOS'
SIMULATOR_NAME      = ENV["SIMULATOR_NAME"] || "iPhone 5"
SDK_BUILD_VERSION   = ENV["SDK_BUILD_VERSION"] || "8.1"
BUILD_CONFIGURATION = ENV["BUILD_CONFIGURATION"] || "Debug"

##############################################################################
# Standard tasks
##############################################################################

task :default do
  system "rake --tasks"
end

desc "Shows the tasks supported"
task :help do
  system "rake --tasks"
end

desc "All in one task to build, test, generate report and open them."
task :go => ['test', 'lint', 'cov', 'reports']

desc "Task for CI Box"
task :ci => ['test','lint','cov']

desc "Cleans the build artifacts"
task :clean do
  xcbuild('clean')
  run_cmd('rm -rf build')
end

desc "Builds the application"
task :build => :clean do
  xcbuild('clean build')
end

desc "Tests the application"
task :test => :clean do
  close_simulator
  xcbuild("clean test", "--test -r html --output '#{REPORTS_DIR}/tests.html'")
  close_simulator
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
task :cov => :gencov do
  run_cmd("#{XCODECOVERAGE_DIR}/cicov", "cicov")
  run_cmd("ln -s #{REPORTS_DIR}/lcov/index.html #{REPORTS_DIR}/codecoverage.html", "Code Coverage Report")
  puts "\nCode Coverage Finished, open #{REPORTS_DIR}/codecoverage.html to view results".green
end

task :gencov do
  run_cmd("xcodebuild \
              -workspace TitanIOS.xcworkspace \
              -scheme TitanIOS \
              -sdk iphonesimulator#{SDK_BUILD_VERSION} \
              -destination platform='iOS Simulator',OS=#{SDK_BUILD_VERSION},name='iPhone Retina (4-inch)' \
              -configuration #{BUILD_CONFIGURATION} \
              -showBuildSettings | \
          egrep '( BUILT_PRODUCTS_DIR)|(NATIVE_ARCH )|(OBJECT_FILE_DIR_normal)|(SRCROOT)|(OBJROOT)' \
          | tr -d ' ' | sed -e 's/^/export /' | sed -e 's/$/\"/' | sed 's/=/=\"/g' | sed 's/NATIVE_ARCH/CURRENT_ARCH/' \> #{XCODECOVERAGE_DIR}/env.sh",
          "Load Build Variables")
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

  xcodebuild = "xcodebuild \
                  -workspace #{WORKSPACE} \
                  -scheme #{SCHEME} \
                  -sdk iphonesimulator#{SDK_BUILD_VERSION} \
                  -destination platform='iOS Simulator',OS=#{SDK_BUILD_VERSION},name='iPhone Retina (4-inch)' \
                  -configuration #{BUILD_CONFIGURATION} \
                  #{build_type} 2>&1 | \
                  tee #{XCBUILD_LOG} "

  if XCPRETTY_AVALIABLE
    run_cmd(xcodebuild +
            "2>&1 | xcpretty -c --no-utf #{xcpretty_args}; \
            exit ${PIPESTATUS[0]}",
            "xcodebuild " + build_type)
  else
    run_cmd(xcodebuild, "xcodebuild " + build_type)
  end
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
