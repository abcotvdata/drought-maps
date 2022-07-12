
# libraries

library(dplyr)
library(readr)
library(stringr)
library(leaflet)
library(leaflet.extras)
library(leaflet.providers)
library(sf)
library(htmlwidgets)
library(here)


# downloading new shapefile

shapefile_zip <- "https://droughtmonitor.unl.edu/data/shapefiles_m/USDM_current_M.zip"
url <- paste0(shapefile_zip, "?v=", gsub(" |:", "-", as.character(Sys.time())))
download.file(shapefile_zip, "USDM_current_M.zip")
unzip("USDM_current_M.zip")
shp <- list.files(pattern = "(.*)\\.shp$")

drought_shapefile <- here(shp) %>%
  st_read()


# maps!

pal <- colorFactor(
  palette = c("#FEFF00", "#FBD37F", "#FFAA00", "#E60000", "#730000"),
  domain = drought_shapefile$`OBJECTID`,
  na.color = "gray",
  reverse = FALSE
)

labels <- c("Abnormally Dry", "Moderate Drought", "Severe Drought", "Extreme Drought", "Exceptional Drought")

tag.map.title <- tags$style(HTML("
  .leaflet-control.map-title {
    position: fixed !important;
    right: 0%;
    bottom: 6px;
    text-align: right;
    padding: 10px;
    background: rgba(255,255,255,0.75);
    font-style: italic;
    font-size: 10px;
  }
  @media only screen and (max-width: 460px) {
    .leaflet-control.map-title {
      font-size: 8px;
    }
  }
"))

title <- tags$div(
  tag.map.title, HTML("Sources: the National Drought Mitigation Center, USDA and NOAA"))

drought_map <- leaflet(options = leafletOptions(zoomControl = FALSE, hoverToWake=FALSE)) %>%
  htmlwidgets::onRender("function(el, x) {
        L.control.zoom({ position: 'topleft' }).addTo(this)
    }") %>%
  addMapPane(name = "polygons", zIndex = 410) %>% 
  addMapPane(name = "maplabels", zIndex = 420) %>%
  addProviderTiles(providers$CartoDB.PositronNoLabels, options = leafletOptions(zoomControl = FALSE, minZoom = 6, maxZoom = 10, dragging = FALSE)) %>%
  addProviderTiles(providers$CartoDB.PositronOnlyLabels, options = leafletOptions(pane = "maplabels", zoomControl = FALSE, minZoom = 6, maxZoom = 10, dragging = FALSE), group = "map labels") %>%
  setView(-122.1484334,37.8427456, zoom = 8) %>%
  addPolygons(data = drought_shapefile, 
              color = "gray", 
              #group = "All Appraisals",
              fillColor = ~pal(`OBJECTID`),
              #label = popups_all, 
              labelOptions = labelOptions(
                direction = "auto",
                style = list("max-width" = "300px")),
              weight = 0.5, 
              fillOpacity = 0.6, 
              # highlight = highlightOptions(
              #   weight = 2,
              #   color = "gray",
              #   opacity = 0.8,
              #   bringToFront = TRUE,
              #   sendToBack = TRUE),
              options = leafletOptions(pane = "polygons")) %>% 
  addLegend(values = drought_shapefile$`OBJECTID`, title = "Drought Intensity",
             labFormat = function(type, cuts, p) {
                                                  paste0(labels)
                             },
            pal = pal,
            position = 'bottomleft',
            na.label = "No Data",
            opacity = 1) %>% 
  addControl(title, position = "bottomright", className="map-title")

la_drought_map <- leaflet(options = leafletOptions(zoomControl = FALSE, hoverToWake=FALSE)) %>%
  htmlwidgets::onRender("function(el, x) {
        L.control.zoom({ position: 'topleft' }).addTo(this)
    }") %>%
  addMapPane(name = "polygons", zIndex = 410) %>% 
  addMapPane(name = "maplabels", zIndex = 420) %>%
  addProviderTiles(providers$CartoDB.PositronNoLabels, options = leafletOptions(zoomControl = FALSE, minZoom = 6, maxZoom = 10, dragging = FALSE)) %>%
  addProviderTiles(providers$CartoDB.PositronOnlyLabels, options = leafletOptions(pane = "maplabels", zoomControl = FALSE, minZoom = 6, maxZoom = 10, dragging = FALSE), group = "map labels") %>%
  setView(-118.1484334,33.9427456, zoom = 8) %>%
  addPolygons(data = drought_shapefile, 
              color = "gray", 
              #group = "All Appraisals",
              fillColor = ~pal(`OBJECTID`),
              #label = popups_all, 
              labelOptions = labelOptions(
                direction = "auto",
                style = list("max-width" = "300px")),
              weight = 0.5, 
              fillOpacity = 0.6, 
              # highlight = highlightOptions(
              #   weight = 2,
              #   color = "gray",
              #   opacity = 0.8,
              #   bringToFront = TRUE,
              #   sendToBack = TRUE),
              options = leafletOptions(pane = "polygons")) %>% 
  addLegend(values = drought_shapefile$`OBJECTID`, title = "Drought Intensity",
             labFormat = function(type, cuts, p) {
                                                  paste0(labels)
                             },
            pal = pal,
            position = 'bottomleft',
            na.label = "No Data",
            opacity = 1) %>% 
  addControl(title, position = "bottomright", className="map-title")


# saving the maps

saveWidget(drought_map, 'sf_drought_map.html', selfcontained = TRUE)
saveWidget(la_drought_map, 'la_drought_map.html', selfcontained = TRUE)

