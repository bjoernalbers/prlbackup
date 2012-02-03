# A sample Guardfile
# More info at https://github.com/guard/guard#readme

guard 'cucumber' do
  watch(%r{^bin/.+$})                 { 'features' }
  watch(%r{^lib/.+$})                 { 'features' }
  watch(%r{^features/.+\.feature$})
  watch(%r{^features/support/.+$})    { 'features' }
  watch(%r{^features/steps/.+$})       { 'features' }
end
