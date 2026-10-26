package com.fenglin.springboottest.controller;

import com.fenglin.springboottest.common.Result;
import com.fenglin.springboottest.dto.CategoryVO;
import com.fenglin.springboottest.dto.HomeFeedVO;
import com.fenglin.springboottest.dto.PostVO;
import com.fenglin.springboottest.entity.HomeCategory;
import com.fenglin.springboottest.entity.HomeHotKeyword;
import com.fenglin.springboottest.entity.HomePost;
import com.fenglin.springboottest.mapper.HomeCategoryMapper;
import com.fenglin.springboottest.mapper.HomeHotKeywordMapper;
import com.fenglin.springboottest.mapper.HomePostMapper;
import com.baomidou.mybatisplus.core.toolkit.Wrappers;
import java.time.format.DateTimeFormatter;
import java.util.List;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

/**
 * 首页展示数据接口（数据源即后台管理系统维护的 home_* 三张表）。
 * GET /api/home/feed  首页聚合数据：分类 + 精选内容 + 热门搜索词
 * GET /api/search     站内搜索
 */
@RestController
@RequestMapping("/api")
public class HomeController {

    private static final DateTimeFormatter DATE_FMT = DateTimeFormatter.ofPattern("MM-dd");

    private final HomeCategoryMapper categoryMapper;
    private final HomePostMapper postMapper;
    private final HomeHotKeywordMapper hotKeywordMapper;

    public HomeController(HomeCategoryMapper categoryMapper,
                          HomePostMapper postMapper,
                          HomeHotKeywordMapper hotKeywordMapper) {
        this.categoryMapper = categoryMapper;
        this.postMapper = postMapper;
        this.hotKeywordMapper = hotKeywordMapper;
    }

    /** 首页聚合数据：GET /api/home/feed */
    @GetMapping("/home/feed")
    public Result<HomeFeedVO> feed() {
        List<CategoryVO> categories = categoryMapper.selectList(
                        Wrappers.<HomeCategory>lambdaQuery()
                                .eq(HomeCategory::getStatus, 1)
                                .orderByDesc(HomeCategory::getSortWeight)
                                .orderByAsc(HomeCategory::getId))
                .stream()
                .map(c -> new CategoryVO(c.getId(), c.getIcon(), c.getName(), c.getSummary(), c.getKeyword()))
                .toList();

        List<PostVO> posts = publishedPosts().stream().map(HomeController::toVO).toList();

        List<String> hotKeywords = hotKeywordMapper.selectList(
                        Wrappers.<HomeHotKeyword>lambdaQuery()
                                .eq(HomeHotKeyword::getStatus, 1)
                                .orderByDesc(HomeHotKeyword::getSortWeight)
                                .orderByDesc(HomeHotKeyword::getHeat))
                .stream()
                .map(HomeHotKeyword::getKeyword)
                .toList();

        return Result.success(new HomeFeedVO(categories, posts, hotKeywords));
    }

    /** 站内搜索：GET /api/search?keyword=xxx&size=20 */
    @GetMapping("/search")
    public Result<List<PostVO>> search(@RequestParam(value = "keyword", defaultValue = "") String keyword,
                                       @RequestParam(value = "size", defaultValue = "20") int size) {
        String kw = keyword == null ? "" : keyword.trim();
        List<HomePost> list;
        if (kw.isEmpty()) {
            list = publishedPosts();
        } else {
            list = postMapper.selectList(
                    Wrappers.<HomePost>lambdaQuery()
                            .eq(HomePost::getStatus, 1)
                            .and(w -> w.like(HomePost::getTitle, kw)
                                    .or().like(HomePost::getSummary, kw)
                                    .or().like(HomePost::getCategory, kw)
                                    .or().like(HomePost::getTags, kw)
                                    .or().like(HomePost::getCity, kw))
                            .orderByDesc(HomePost::getPublishAt)
                            .last("LIMIT " + Math.max(1, Math.min(size, 100))));
        }
        return Result.success(list.stream().map(HomeController::toVO).toList());
    }

    private List<HomePost> publishedPosts() {
        return postMapper.selectList(
                Wrappers.<HomePost>lambdaQuery()
                        .eq(HomePost::getStatus, 1)
                        .orderByDesc(HomePost::getSortWeight)
                        .orderByDesc(HomePost::getPublishAt));
    }

    private static PostVO toVO(HomePost p) {
        return new PostVO(
                p.getId(),
                p.getCategory(),
                p.getPublishAt() == null ? "" : p.getPublishAt().format(DATE_FMT),
                p.getTitle(),
                p.getSummary(),
                p.getAuthor(),
                p.getCity(),
                p.getReadCount(),
                p.getLikeCount(),
                p.getTags()
        );
    }
}
