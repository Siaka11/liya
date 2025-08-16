#!/usr/bin/env ruby

require 'xcodeproj'

# Ouvre le projet Xcode
project = Xcodeproj::Project.open('Runner.xcodeproj')

# Trouve la target principale
target = project.targets.find { |t| t.name == 'Runner' }

if target.nil?
  puts "❌ Target 'Runner' not found"
  exit 1
end

# Ajoute les capacités pour les notifications push
capabilities = target.build_configurations.first.build_settings
capabilities['CODE_SIGN_ENTITLEMENTS'] = 'Runner/Runner.entitlements'

# Trouve les fichiers de build settings
target.build_configurations.each do |config|
  config.build_settings['CODE_SIGN_ENTITLEMENTS'] = 'Runner/Runner.entitlements'
  config.build_settings['ENABLE_PUSH_NOTIFICATIONS'] = 'YES'
  config.build_settings['ENABLE_BACKGROUND_MODES'] = 'YES'
end

# Sauvegarde le projet
project.save

puts "✅ Configuration des notifications push ajoutée avec succès!"
puts "📝 Prochaines étapes :"
puts "   1. Ouvrez Xcode"
puts "   2. Sélectionnez la target 'Runner'"
puts "   3. Allez dans 'Signing & Capabilities'"
puts "   4. Cliquez sur '+ Capability'"
puts "   5. Ajoutez 'Push Notifications'"
puts "   6. Ajoutez 'Background Modes' si pas déjà présent"
puts "   7. Dans Background Modes, cochez 'Remote notifications'" 