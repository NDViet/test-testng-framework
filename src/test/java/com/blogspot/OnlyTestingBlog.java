package com.blogspot;

import org.ndviet.library.BrowserManagement;
import org.ndviet.library.WebUI;
import org.testng.annotations.AfterMethod;
import org.testng.annotations.BeforeMethod;
import org.testng.annotations.Test;

import java.util.Arrays;
import java.util.Map;

import static org.ndviet.library.TestObject.ObjectRepository.findTestObject;
import static org.ndviet.library.configuration.Constants.TEST_DATA_DIRECTORY;
import static org.ndviet.library.file.FileHelpers.getPath;

public class OnlyTestingBlog {
    @BeforeMethod
    public void beforeTest() {
        BrowserManagement.getInstance().openBrowser("http://only-testing-blog.blogspot.com/2013/09/test.html");
    }

    @AfterMethod
    public void afterTest() {
        BrowserManagement.getInstance().closeBrowser();
    }

    @Test
    public void BasicTest() throws Exception {
        WebUI.verifyElementPresent(findTestObject("Only Testing Blog.Choose File"));
        WebUI.uploadFile(findTestObject("Only Testing Blog.Choose File"), getPath(System.getProperty(TEST_DATA_DIRECTORY) + "/" + "SampleFile.yml"));
        for (String country : Arrays.asList("USA", "Japan", "Germany")) {
            WebUI.click(findTestObject("Only Testing Blog.Available Country", Map.of("value", country)));
            WebUI.click(findTestObject("Only Testing Blog.Add Country Button"));
            WebUI.verifyElementNotVisible(findTestObject("Only Testing Blog.Available Country", Map.of("value", country)));
            WebUI.verifyElementVisible(findTestObject("Only Testing Blog.Selected Country", Map.of("value", country)));
        }
        for (String country : Arrays.asList("USA")) {
            WebUI.click(findTestObject("Only Testing Blog.Selected Country", Map.of("value", country)));
            WebUI.click(findTestObject("Only Testing Blog.Remove Country Button"));
            WebUI.verifyElementNotVisible(findTestObject("Only Testing Blog.Selected Country", Map.of("value", country)));
            WebUI.verifyElementVisible(findTestObject("Only Testing Blog.Available Country", Map.of("value", country)));
        }
        WebUI.click(findTestObject("Only Testing Blog.Submit Button"), 20);
        WebUI.click(findTestObject("Only Testing Blog.Submit Button"), 21);
    }
}
