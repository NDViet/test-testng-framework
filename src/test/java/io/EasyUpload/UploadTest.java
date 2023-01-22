package io.EasyUpload;

import org.ndviet.library.BrowserManagement;
import org.ndviet.library.TakeScreenshot;
import org.ndviet.library.WebUI;
import org.testng.annotations.AfterMethod;
import org.testng.annotations.BeforeMethod;
import org.testng.annotations.Test;

import java.util.Map;

import static org.ndviet.library.TestObject.ObjectRepository.findTestObject;
import static org.ndviet.library.configuration.Constants.TEST_DATA_DIRECTORY;
import static org.ndviet.library.file.FileHelpers.getPath;

public class UploadTest {
    @BeforeMethod
    public void beforeTest() {
        BrowserManagement.getInstance().openBrowser("https://easyupload.io/");
    }

    @AfterMethod
    public void afterTest() {
        BrowserManagement.getInstance().closeBrowser();
    }

    @Test
    public void uploadFile() throws Exception {
        WebUI.verifyElementVisible(findTestObject("Easy Upload.Upload.Drop Zone"));
        TakeScreenshot.capturePageScreenshot(null);
        WebUI.uploadFile(findTestObject("Easy Upload.Upload.File"), getPath(System.getProperty(TEST_DATA_DIRECTORY) + "/" + "SampleFile.yml"));
        WebUI.click(findTestObject("Easy Upload.Upload.Settings.Expiration Dropdown"));
        WebUI.click(findTestObject("Easy Upload.Upload.Settings.Option", Map.of("value", "1 days")));
        TakeScreenshot.capturePageScreenshot(null);
        WebUI.click(findTestObject("Easy Upload.Upload.Submit Button"));
        TakeScreenshot.capturePageScreenshot(null);
        WebUI.verifyElementVisible(findTestObject("Easy Upload.Upload.Link"));
        TakeScreenshot.capturePageScreenshot(null);
    }
}
