output "bronze_bucket_name" {
  description = "Nome do bucket da camada Bronze (RAW)."
  value       = google_storage_bucket.primary_lake["bronze"].name
}

output "bronze_bucket_url" {
  description = "URL do bucket da camada Bronze (RAW)."
  value       = google_storage_bucket.primary_lake["bronze"].url
}

output "silver_bucket_name" {
  description = "Nome do bucket da camada Silver (Trusted COGs)."
  value       = google_storage_bucket.primary_lake["silver"].name
}

output "silver_bucket_url" {
  description = "URL do bucket da camada Silver (Trusted COGs)."
  value       = google_storage_bucket.primary_lake["silver"].url
}

output "gold_bucket_name" {
  description = "Nome do bucket da camada Gold (Refined)."
  value       = google_storage_bucket.primary_lake["gold"].name
}

output "gold_bucket_url" {
  description = "URL do bucket da camada Gold (Refined)."
  value       = google_storage_bucket.primary_lake["gold"].url
}

output "gee_publication_bucket_name" {
  description = "Nome do bucket de publicação no Google Earth Engine (us-central1)."
  value       = google_storage_bucket.gee_publication.name
}

output "gee_publication_bucket_url" {
  description = "URL do bucket de publicação no Google Earth Engine (us-central1)."
  value       = google_storage_bucket.gee_publication.url
}

output "buckets" {
  description = "Mapa consolidado com todos os buckets criados no GeoDataLake."
  value = {
    bronze = {
      name      = google_storage_bucket.primary_lake["bronze"].name
      url       = google_storage_bucket.primary_lake["bronze"].url
      self_link = google_storage_bucket.primary_lake["bronze"].self_link
      location  = google_storage_bucket.primary_lake["bronze"].location
    }
    silver = {
      name      = google_storage_bucket.primary_lake["silver"].name
      url       = google_storage_bucket.primary_lake["silver"].url
      self_link = google_storage_bucket.primary_lake["silver"].self_link
      location  = google_storage_bucket.primary_lake["silver"].location
    }
    gold = {
      name      = google_storage_bucket.primary_lake["gold"].name
      url       = google_storage_bucket.primary_lake["gold"].url
      self_link = google_storage_bucket.primary_lake["gold"].self_link
      location  = google_storage_bucket.primary_lake["gold"].location
    }
    gee_publication = {
      name      = google_storage_bucket.gee_publication.name
      url       = google_storage_bucket.gee_publication.url
      self_link = google_storage_bucket.gee_publication.self_link
      location  = google_storage_bucket.gee_publication.location
    }
  }
}

