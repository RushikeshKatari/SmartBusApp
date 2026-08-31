package com.smartbus.tracking.controller;

import com.smartbus.tracking.dto.LocationUpdate;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.handler.annotation.SendTo;
import org.springframework.stereotype.Controller;

@Controller
public class TrackingController {

    @MessageMapping("/updateLocation")
    @SendTo("/topic/busLocations")
    public LocationUpdate processLocationUpdate(LocationUpdate update) {
        // In a perfect backend, this would also write to Redis for caching.
        return update;
    }
}
