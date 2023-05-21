variable "staging_crawler_role" {
    type = string
}

resource "aws_glue_catalog_database" "glue_catalog_database" {
  name = "ecommerce-database-new"
}

resource "aws_glue_crawler" "staging-crawler" {
    database_name = aws_glue_catalog_database.glue_catalog_database.name
    name = "orders_staging_crawler_new"
    role = var.staging_crawler_role

    s3_target {
      path = "s3://vinod-streaming-project-staging-bucket/"
    }
}

output "glue_staging_crawler_arn" {
  value = aws_glue_crawler.staging-crawler.arn
}