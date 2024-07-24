package com.testcontainers.catalog.ui;

import java.io.File;

import org.junit.Test;
import org.openqa.selenium.chrome.ChromeOptions;
import org.openqa.selenium.remote.RemoteWebDriver;
import org.testcontainers.containers.BrowserWebDriverContainer;
import org.testcontainers.containers.VncRecordingContainer;
import org.testcontainers.junit.jupiter.Container;

public class SeleniumExampleTest {
    @Container
    private static final BrowserWebDriverContainer chrome = new BrowserWebDriverContainer()
            .withCapabilities(new ChromeOptions())
            .withRecordingMode(BrowserWebDriverContainer.VncRecordingMode.RECORD_ALL, new File("build"));

    @Test
    public void simplePlainSeleniumTest() {
        chrome.start();
        RemoteWebDriver driver = new RemoteWebDriver(chrome.getSeleniumAddress(), new ChromeOptions());

        driver.get("https://testcontainers.com/");
        assert "Testcontainers".equals(driver.getTitle());
    }
}
