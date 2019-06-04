future_add_library(${PROJECT_NAME} greetings.cpp)
target_link_libraries(${PROJECT_NAME} PUBLIC ${PROJECT_NAME}::headers)
