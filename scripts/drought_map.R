
# libraries

library(dplyr)
library(readr)
library(stringr)
library(leaflet)
library(leaflet.extras)
library(leaflet.providers)
library(sf)
library(htmlwidgets)
library(htmltools)
library(here)

# delete old files

file.remove(list.files(pattern = "(.*)\\.shp$"))
file.remove(list.files(pattern = "(.*)\\.cpg$"))
file.remove(list.files(pattern = "(.*)\\.dbf$"))
file.remove(list.files(pattern = "(.*)\\.prj$"))
file.remove(list.files(pattern = "(.*)\\.sbn$"))
file.remove(list.files(pattern = "(.*)\\.sbx$"))
file.remove(list.files(pattern = "(.*)\\.xml$"))
file.remove(list.files(pattern = "(.*)\\.shx$"))

# downloading new shapefile

shapefile_zip <- "https://droughtmonitor.unl.edu/data/shapefiles_m/USDM_current_M.zip"
# url <- paste0(shapefile_zip, "?v=", gsub(" |:", "-", as.character(Sys.time())))
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
    left: 5px;
    top: 5px;
    width: 30%;
    text-align: left;
    padding: 10px;
    color: white;
  }
  .leaflet-control.map-title .subheadline {
    font-size: 14px;
    color: black;
    padding: 5px 30px 5px 10px;
    background: linear-gradient(90deg, rgba(255,255,255,1) 90%, rgba(255,255,255,0) 100%);
    border-radius: 0px 0px 4px 4px;
  }
  .leaflet-control.map-title .subheadline a {
    color: #BE0000;
    font-weight: bold;
  }
  @media only screen and (max-width: 460px) {
    .leaflet-control.map-title {
      font-size: 15px;
    }
    .leaflet-control.map-title .subheadline {
      font-size: 9px;
    border-radius: 0px 0px 4px 4px;
    }
"))

title <- tags$div(
  tag.map.title, HTML('<div style="font-weight: bold; font-size: 20px; padding: 10px; background: linear-gradient(90deg, rgba(190,0,0,1) 0%, rgba(249,140,0,1) 43%, rgba(255,186,0,1) 90%, rgba(255,186,0,0) 100%);">Drought Tracker</div> <div class="subheadline">ABC7 is tracking drought conditions across California. The colors on the map show drought intensity, ranging from "abnormally dry" in yellow to "exceptional drought" in dark red.</div>')
  )

tag.map.footer <- tags$style(HTML("
  .leaflet-control.map-footer {
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
    .leaflet-control.map-footer {
      font-size: 8px;
    }
  }
"))

today_UTC <- as.POSIXct(Sys.time())
today_posix <- format(today_UTC, tz="America/Los_Angeles",usetz=TRUE)
today <- as.Date(substr(as.character(today_posix), 1,10))
today_display <- format(today, "%A, %b. %d, %Y")

footer <- tags$div(
  tag.map.footer, HTML("<div> Sources: the National Drought Mitigation Center, USDA and NOAA. </div> <div>Last updated",today_display,))

drought_map <- leaflet(options = leafletOptions(zoomControl = FALSE, hoverToWake=FALSE)) %>%
  htmlwidgets::onRender("function(el, x) {
        L.control.zoom({ position: 'topright' }).addTo(this)
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
  addControl(footer, position = "bottomright", className="map-footer") %>% 
  addControl(title, position = "topleft", className="map-title") 


la_drought_map <- leaflet(options = leafletOptions(zoomControl = FALSE, hoverToWake=FALSE)) %>%
  htmlwidgets::onRender("function(el, x) {
        L.control.zoom({ position: 'topright' }).addTo(this)
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
  addControl(footer, position = "bottomright", className="map-footer") %>% 
    addControl(title, position = "topleft", className="map-title") 



# saving the maps

saveWidget(drought_map, 'sf_drought_map.html', selfcontained = TRUE)
saveWidget(la_drought_map, 'la_drought_map.html', selfcontained = TRUE)

