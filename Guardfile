# A sample Guardfile
# More info at https://github.com/guard/guard#readme

guard 'rspec', :version => 2, :cli => '--color' do
  watch(%r{^spec/.+_spec\.rb$})
  watch(%r{^lib/(.+)\.rb$})           { |m| "spec/#{m[1]}_spec.rb" }
  watch('spec/spec_helper.rb')        { "spec" }
end

guard 'cucumber' do
  watch(%r{^bin/.+$})                 { 'features' }
  watch(%r{^lib/.+$})                 { 'features' }
  watch(%r{^features/.+\.feature$})
  watch(%r{^features/support/.+$})    { 'features' }
  watch(%r{^features/steps/.+$})       { 'features' }
end
