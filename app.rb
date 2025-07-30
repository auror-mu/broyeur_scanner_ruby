require 'sinatra'
require 'csv'
require 'open-uri'
require 'json'

set :bind, '0.0.0.0'

CSV_URL = "https://drive.google.com/uc?export=download&id=1lIKfZ4qKLxOKF9llNgkUA8RXP7EhnBkA"
LOCAL_CSV = "produits.csv"

def telecharger_csv
  return if File.exist?(LOCAL_CSV)

  puts "📥 Téléchargement du fichier depuis Google Drive..."
  URI.open(CSV_URL) do |remote_file|
    File.open(LOCAL_CSV, "wb") do |local_file|
      local_file.write(remote_file.read)
    end
  end
  puts "✅ CSV téléchargé."
rescue => e
  puts "❌ Erreur lors du téléchargement : #{e.message}"
end

def charger_produits
  telecharger_csv
  produits = {}
  CSV.foreach(LOCAL_CSV, headers: true, col_sep: ";") do |row|
    code = row["CODE EAN"]&.strip
    next unless code && !code.empty?

    nom = row["NOM DU PRODUIT"].strip
    prix_str = row["PRIX DE VENTE TTC"].gsub(",", ".").gsub(/[^\d.]/, "")
    begin
      prix = prix_str.to_f
      produits[code] = { nom: nom, prix: prix }
    rescue
      puts "⚠️ Prix invalide pour #{nom} : #{row['PRIX DE VENTE TTC']}"
    end
  end
  produits
end

PRODUITS = charger_produits

post '/' do
  code = params[:barcode].strip
  produit = PRODUITS[code]
  if produit
    # ici, tu peux afficher la page avec ce produit, ou faire autre chose
    erb :index, locals: { produit: produit }
  else
    status 404
    "Produit non trouvé"
  end
end
