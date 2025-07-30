# config/puma.rb

workers Integer(ENV.fetch("WEB_CONCURRENCY") { 2 })
threads_count = Integer(ENV.fetch("RAILS_MAX_THREADS") { 5 })
threads threads_count, threads_count

preload_app!

port        ENV.fetch("PORT") { 3000 }
environment ENV.fetch("RACK_ENV") { "development" }

# On Heroku, ça permet de redémarrer proprement le serveur
on_worker_boot do
  # Code à exécuter après le démarrage d’un worker (ex: reconnecter DB)
end
