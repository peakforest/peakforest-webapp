/**
 * 
 */
package fr.metabohub.peakforest.controllers;

import static org.hamcrest.Matchers.startsWith;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultHandlers.print;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.content;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;
import static org.springframework.test.web.servlet.setup.MockMvcBuilders.webAppContextSetup;

import java.util.ResourceBundle;

import org.junit.After;
import org.junit.AfterClass;
import org.junit.Before;
import org.junit.BeforeClass;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.http.MediaType;
import org.springframework.test.context.junit4.SpringJUnit4ClassRunner;
import org.springframework.test.web.servlet.MockMvc;

import fr.metabohub.peakforest.controllers.ToolsController;
import fr.metabohub.peakforest.mvc.AbstractContextControllerTests;
import fr.metabohub.peakforest.utils.Utils;

/**
 * Test the methods in {@link ToolsController} controller
 * 
 * @author Nils Paulhe
 * 
 */
@RunWith(SpringJUnit4ClassRunner.class)
public class ToolsControllerTest extends AbstractContextControllerTests {

	private MockMvc mockMvc;

	@BeforeClass
	public static void setUpBeforeClass() throws Exception {
	}

	@AfterClass
	public static void tearDownAfterClass() throws Exception {
	}

	@Before
	public void setUp() throws Exception {
		this.mockMvc = webAppContextSetup(this.wac).alwaysExpect(status().isOk()).build();
		Utils.setBundleConf(ResourceBundle.getBundle("confTest"));
	}

	@After
	public void tearDown() throws Exception {
	}

	/**
	 * Test /search simple request
	 * 
	 * @throws Exception
	 */
	@Test
	public void searchTest() throws Exception {
		this.mockMvc
				.perform(post("/search").accept(MediaType.APPLICATION_JSON).param("query", "lorem ipsum"))
				.andDo(print()).andExpect(status().isOk())
				.andExpect(content().string(startsWith("{\"compounds")));

	}

}
