export default {
  spec_dir: "spec/javascripts",
  spec_files: [
    "**/*[sS]pec.js"
  ],
  helpers: [
    "helpers/**/*.js"
  ],
  env: {
    stopSpecOnExpectationFailure: false,
    random: false,
    forbidDuplicateNames: true
  }
}
