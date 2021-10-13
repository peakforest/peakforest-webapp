/**
 * 
 */
package fr.metabohub.peakforest.controllers;

import static org.hamcrest.Matchers.startsWith;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultHandlers.print;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.content;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import java.util.ResourceBundle;

import org.junit.After;
import org.junit.AfterClass;
import org.junit.Before;
import org.junit.BeforeClass;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.MediaType;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit4.SpringJUnit4ClassRunner;
import org.springframework.test.context.web.WebAppConfiguration;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.setup.MockMvcBuilders;
import org.springframework.web.context.WebApplicationContext;
import org.springframework.web.servlet.config.annotation.EnableWebMvc;

import fr.metabohub.peakforest.utils.PeakForestUtils;

/**
 * Test the methods in {@link ToolsController} controller
 * 
 * @author Nils Paulhe
 * 
 */
@RunWith(SpringJUnit4ClassRunner.class)
@ContextConfiguration
@WebAppConfiguration
public class ToolsControllerTest {

	@Autowired
	private WebApplicationContext ctx;

	private MockMvc mockMvc;

	@BeforeClass
	public static void setUpBeforeClass() throws Exception {
	}

	@AfterClass
	public static void tearDownAfterClass() throws Exception {
	}

	@Before
	public void setUp() throws Exception {
		this.mockMvc = MockMvcBuilders.webAppContextSetup(ctx).build();
		PeakForestUtils.setBundleConf(ResourceBundle.getBundle("confTest"));
	}

	@After
	public void tearDown() throws Exception {
	}

	@Configuration
	@EnableWebMvc
	public static class TestConfiguration {

		@Bean
		public ToolsController testController() {
			return new ToolsController();
		}

	}

	/**
	 * Test /search simple request
	 * 
	 * @throws Exception
	 */
	@Test
	public void searchTest() throws Exception {
		this.mockMvc
				.perform(post("/search").accept(MediaType.APPLICATION_JSON).param("query", "lorem ipsum").param("quick",
						"false"))
				.andDo(print()).andExpect(status().isOk())
				.andExpect(content().string(startsWith("{\"success\":true,\"compoundNames\":[],\"compounds\":[]}")));

	}

}
