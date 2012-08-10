
def in_temp_dir
  tmpdir = "test-tmp.#$$"
  pwd = Dir.pwd
  Dir.mkdir(tmpdir)
  Dir.chdir(tmpdir)
  begin
    yield
  ensure
    Dir.chdir(pwd)
    Dir.rmdir(tmpdir)
  end
end

def remove_file(file)
  if File.exist? file
    File.unlink(file)
  end
end
