package com.demoqa;

import org.ndviet.library.WebUI;
import org.testng.annotations.AfterMethod;
import org.testng.annotations.BeforeMethod;
import org.testng.annotations.Parameters;
import org.testng.annotations.Test;

import static org.ndviet.library.TestObject.ObjectRepository.findTestObject;
public class DownloadTest {
    @Parameters("browser")
    @BeforeMethod
    public void beforeTest(String browser) {
        WebUI.openBrowser(browser, "https://demoqa.com/upload-download");
    }

    @AfterMethod
    public void afterTest() {
        //WebUI.closeBrowser();
    }

    @Test
    public void BasicTest() throws Exception {
        WebUI.verifyElementPresent(findTestObject("DemoQA.UploadDownload.btnDownload"));
        WebUI.click(findTestObject("DemoQA.UploadDownload.btnDownload"), 20);
    }
}
