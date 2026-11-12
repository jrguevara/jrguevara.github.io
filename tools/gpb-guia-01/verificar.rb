require 'nokogiri'
require 'json'
require 'uri'
require 'digest'
require 'open3'

# Ejecutar desde la raíz: bundle exec ruby tools/gpb-guia-01/verificar.rb /ruta/al/sitio-generado
original = File.read('assets/downloads/gpb/guia-01/guias/01-CONFIGURACION-Y-AUTENTICACION.md')
post = File.read('_posts/2026-11-11-gpb-guia-01-configuracion-y-autenticacion.md')
blocks = ->(s) { s.scan(/^```([^\n]*)\n(.*?)^```[ \t]*$/m) }
raise 'Los bloques Markdown cambiaron' unless blocks.call(original).map(&:last) == blocks.call(post).map(&:last)
root = ARGV.fetch(0, '_site')
doc = Nokogiri::HTML(File.read("#{root}/posts/gpb-guia-01-configuracion-y-autenticacion/index.html"))
content = doc.at_css('.post-content')
rendered = content.css('div.highlight').map { |h| (h.at_css('td.rouge-code pre') || h.at_css('pre')).text }
expected = blocks.call(original).map(&:last)
raise "Número de bloques: #{rendered.size} != #{expected.size}" unless rendered.size == expected.size
rendered.zip(expected).each_with_index { |(a,b),i| raise "Código renderizado distinto en bloque #{i+1}" unless a == b }
ids = content.css('[id]').map { |n| n['id'] }
links = content.css('a[href]')
links.each do |a|
 href = a['href']
 if href.start_with?('#')
  raise "Ancla rota: #{href}" unless ids.include?(URI::DEFAULT_PARSER.unescape(href[1..]))
 elsif href.start_with?('/')
  path = "#{root}#{URI::DEFAULT_PARSER.unescape(href.split('#')[0])}"
  raise "Recurso ausente: #{href}" unless File.exist?(path)
 elsif href.start_with?('file:', '../', '/Users/', '/private/')
  raise "Enlace local: #{href}"
 end
end
puts JSON.pretty_generate({bloques_markdown_identicos: expected.size, bloques_html_identicos: rendered.size, enlaces_revisados: links.size, tablas: content.css('table').reject{|t|t['class'].to_s.include?('rouge-table')}.size, anclas_duplicadas: ids.tally.select{|k,v|v>1}})

package = 'assets/downloads/gpb/guia-01'
Dir.glob("#{package}/**/*").select { |p| File.file?(p) }.each do |p|
  raise "Adjunto alterado al generar: #{p}" unless File.binread(p) == File.binread(File.join(root, p))
end
raise 'La copia original no coincide con el informe' unless Digest::SHA256.hexdigest(original) == 'fecd021e4242baaab820da05172b8cbd50769d64cef55d7c96ed4a2461c18d53'
lock, error, status = Open3.capture3('unzip', '-p', "#{package}/etapas/01/codigo-etapa-1.zip", 'pnpm-lock.yaml')
raise "No se pudo leer el lock: #{error}" unless status.success?
raise 'El lock no coincide con el informe' unless Digest::SHA256.hexdigest(lock) == '907d346cd6fe931b3d79733200b5879445c5126a134e5996466d58248fcc3f78'
puts 'Adjuntos conservados byte a byte; original y pnpm-lock.yaml coinciden con la verificación de GPB.'
