package io.pivotal.demo.sko.ui;

import org.springframework.boot.builder.SpringApplicationBuilder;

public class AppInitializer{// extends SpringBootServletInitializer {

    
    protected SpringApplicationBuilder configure(SpringApplicationBuilder application) {
        return application.sources(WebConsoleApp.class);
    }
}