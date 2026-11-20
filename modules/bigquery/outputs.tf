output "datasets" {
  description = "Mapa de datasets BigQuery criados."
  value = {
    for k, v in google_bigquery_dataset.datasets : k => {
      id         = v.id
      dataset_id = v.dataset_id
      self_link  = v.self_link
      location   = v.location
    }
  }
}

output "gold_analytics_dataset_id" {
  description = "ID do dataset Gold Analytics."
  value       = google_bigquery_dataset.datasets["gold_analytics"].dataset_id
}

output "gis_census_dataset_id" {
  description = "ID do dataset GIS Census."
  value       = google_bigquery_dataset.datasets["gis_census"].dataset_id
}

