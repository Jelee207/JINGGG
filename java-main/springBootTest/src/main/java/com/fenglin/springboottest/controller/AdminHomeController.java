package com.fenglin.springboottest.controller;

import com.baomidou.mybatisplus.core.toolkit.Wrappers;
import com.fenglin.springboottest.common.JwtBlacklist;
import com.fenglin.springboottest.common.JwtUtil;
import com.fenglin.springboottest.common.Result;
import com.fenglin.springboottest.entity.HomeCategory;
import com.fenglin.springboottest.entity.HomeHotKeyword;
import com.fenglin.springboottest.entity.HomePost;
import com.fenglin.springboottest.mapper.HomeCategoryMapper;
import com.fenglin.springboottest.mapper.HomeHotKeywordMapper;
import com.fenglin.springboottest.mapper.HomePostMapper;
import java.time.LocalDateTime;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

/**
 * 后台管理系统 · 首页数据管理。
 * 维护前台首页所展示的全部内容：分类快捷入口、编辑精选内容、热门搜索词。
 * 所有接口需携带 ADMIN 角色令牌（Authorization: Bearer <token>）。
 */
@RestController
@RequestMapping("/api/admin/home")
public class AdminHomeController {

    private final HomeCategoryMapper categoryMapper;
    private final HomePostMapper postMapper;
    private final HomeHotKeywordMapper hotKeywordMapper;
    private final JwtBlacklist blacklist;

    public AdminHomeController(HomeCategoryMapper categoryMapper,
                               HomePostMapper postMapper,
                               HomeHotKeywordMapper hotKeywordMapper,
                               JwtBlacklist blacklist) {
        this.categoryMapper = categoryMapper;
        this.postMapper = postMapper;
        this.hotKeywordMapper = hotKeywordMapper;
        this.blacklist = blacklist;
    }

    /* ============================ 概览统计 ============================ */

    /** GET /api/admin/home/overview */
    @GetMapping("/overview")
    public Object overview(@RequestHeader(value = "Authorization", required = false) String auth) {
        ResponseEntity<Result<Void>> guard = requireAdmin(auth);
        if (guard != null) return guard;

        long categoryOn = categoryMapper.selectCount(
                Wrappers.<HomeCategory>lambdaQuery().eq(HomeCategory::getStatus, 1));
        long postOn = postMapper.selectCount(
                Wrappers.<HomePost>lambdaQuery().eq(HomePost::getStatus, 1));
        long postDraft = postMapper.selectCount(
                Wrappers.<HomePost>lambdaQuery().eq(HomePost::getStatus, 0));
        long keywordOn = hotKeywordMapper.selectCount(
                Wrappers.<HomeHotKeyword>lambdaQuery().eq(HomeHotKeyword::getStatus, 1));

        Map<String, Object> data = new LinkedHashMap<>();
        data.put("categoryCount", categoryMapper.selectCount(Wrappers.<HomeCategory>lambdaQuery()));
        data.put("categoryOnCount", categoryOn);
        data.put("postCount", postMapper.selectCount(Wrappers.<HomePost>lambdaQuery()));
        data.put("postOnCount", postOn);
        data.put("postDraftCount", postDraft);
        data.put("keywordCount", hotKeywordMapper.selectCount(Wrappers.<HomeHotKeyword>lambdaQuery()));
        data.put("keywordOnCount", keywordOn);
        return Result.success(data);
    }

    /* ============================ 分类管理 ============================ */

    /** GET /api/admin/home/categories —— 后台列表含停用项 */
    @GetMapping("/categories")
    public Object listCategories(@RequestHeader(value = "Authorization", required = false) String auth) {
        ResponseEntity<Result<Void>> guard = requireAdmin(auth);
        if (guard != null) return guard;
        List<HomeCategory> list = categoryMapper.selectList(
                Wrappers.<HomeCategory>lambdaQuery()
                        .orderByDesc(HomeCategory::getSortWeight)
                        .orderByAsc(HomeCategory::getId));
        return Result.success(list);
    }

    /** POST /api/admin/home/categories */
    @PostMapping("/categories")
    public Object createCategory(@RequestHeader(value = "Authorization", required = false) String auth,
                                 @RequestBody HomeCategory body) {
        ResponseEntity<Result<Void>> guard = requireAdmin(auth);
        if (guard != null) return guard;
        if (body.getName() == null || body.getName().isBlank()) {
            return Result.error("分类名称不能为空");
        }
        body.setId(null);
        if (body.getIcon() == null || body.getIcon().isBlank()) body.setIcon("✦");
        if (body.getStatus() == null) body.setStatus(1);
        if (body.getSortWeight() == null) body.setSortWeight(0);
        LocalDateTime now = LocalDateTime.now();
        body.setCreatedAt(now);
        body.setUpdatedAt(now);
        categoryMapper.insert(body);
        return Result.success(body);
    }

    /** PUT /api/admin/home/categories/{id} */
    @PutMapping("/categories/{id}")
    public Object updateCategory(@RequestHeader(value = "Authorization", required = false) String auth,
                                 @PathVariable Long id,
                                 @RequestBody HomeCategory body) {
        ResponseEntity<Result<Void>> guard = requireAdmin(auth);
        if (guard != null) return guard;
        HomeCategory exist = categoryMapper.selectById(id);
        if (exist == null) return Result.error("分类不存在或已被删除");
        body.setId(id);
        body.setCreatedAt(exist.getCreatedAt());
        body.setUpdatedAt(LocalDateTime.now());
        categoryMapper.updateById(body);
        return Result.success(body);
    }

    /** DELETE /api/admin/home/categories/{id} */
    @DeleteMapping("/categories/{id}")
    public Object deleteCategory(@RequestHeader(value = "Authorization", required = false) String auth,
                                 @PathVariable Long id) {
        ResponseEntity<Result<Void>> guard = requireAdmin(auth);
        if (guard != null) return guard;
        categoryMapper.deleteById(id);
        return Result.success();
    }

    /* ============================ 内容管理 ============================ */

    /** GET /api/admin/home/posts?keyword=&category= */
    @GetMapping("/posts")
    public Object listPosts(@RequestHeader(value = "Authorization", required = false) String auth,
                            @RequestParam(value = "keyword", defaultValue = "") String keyword,
                            @RequestParam(value = "category", defaultValue = "") String category) {
        ResponseEntity<Result<Void>> guard = requireAdmin(auth);
        if (guard != null) return guard;
        String kw = keyword == null ? "" : keyword.trim();
        String cat = category == null ? "" : category.trim();
        List<HomePost> list = postMapper.selectList(
                Wrappers.<HomePost>lambdaQuery()
                        .like(!kw.isEmpty(), HomePost::getTitle, kw)
                        .eq(!cat.isEmpty(), HomePost::getCategory, cat)
                        .orderByDesc(HomePost::getSortWeight)
                        .orderByDesc(HomePost::getPublishAt)
                        .orderByDesc(HomePost::getId));
        return Result.success(list);
    }

    /** POST /api/admin/home/posts */
    @PostMapping("/posts")
    public Object createPost(@RequestHeader(value = "Authorization", required = false) String auth,
                             @RequestBody HomePost body) {
        ResponseEntity<Result<Void>> guard = requireAdmin(auth);
        if (guard != null) return guard;
        if (body.getTitle() == null || body.getTitle().isBlank()) {
            return Result.error("标题不能为空");
        }
        body.setId(null);
        if (body.getStatus() == null) body.setStatus(1);
        if (body.getSortWeight() == null) body.setSortWeight(0);
        if (body.getReadCount() == null) body.setReadCount(0);
        if (body.getLikeCount() == null) body.setLikeCount(0);
        if (body.getPublishAt() == null) body.setPublishAt(LocalDateTime.now());
        LocalDateTime now = LocalDateTime.now();
        body.setCreatedAt(now);
        body.setUpdatedAt(now);
        postMapper.insert(body);
        return Result.success(body);
    }

    /** PUT /api/admin/home/posts/{id} */
    @PutMapping("/posts/{id}")
    public Object updatePost(@RequestHeader(value = "Authorization", required = false) String auth,
                             @PathVariable Long id,
                             @RequestBody HomePost body) {
        ResponseEntity<Result<Void>> guard = requireAdmin(auth);
        if (guard != null) return guard;
        HomePost exist = postMapper.selectById(id);
        if (exist == null) return Result.error("内容不存在或已被删除");
        body.setId(id);
        body.setCreatedAt(exist.getCreatedAt());
        body.setUpdatedAt(LocalDateTime.now());
        postMapper.updateById(body);
        return Result.success(body);
    }

    /** DELETE /api/admin/home/posts/{id} */
    @DeleteMapping("/posts/{id}")
    public Object deletePost(@RequestHeader(value = "Authorization", required = false) String auth,
                             @PathVariable Long id) {
        ResponseEntity<Result<Void>> guard = requireAdmin(auth);
        if (guard != null) return guard;
        postMapper.deleteById(id);
        return Result.success();
    }

    /* ============================ 热门搜索词 ============================ */

    /** GET /api/admin/home/keywords */
    @GetMapping("/keywords")
    public Object listKeywords(@RequestHeader(value = "Authorization", required = false) String auth) {
        ResponseEntity<Result<Void>> guard = requireAdmin(auth);
        if (guard != null) return guard;
        List<HomeHotKeyword> list = hotKeywordMapper.selectList(
                Wrappers.<HomeHotKeyword>lambdaQuery()
                        .orderByDesc(HomeHotKeyword::getSortWeight)
                        .orderByDesc(HomeHotKeyword::getHeat));
        return Result.success(list);
    }

    /** POST /api/admin/home/keywords */
    @PostMapping("/keywords")
    public Object createKeyword(@RequestHeader(value = "Authorization", required = false) String auth,
                                @RequestBody HomeHotKeyword body) {
        ResponseEntity<Result<Void>> guard = requireAdmin(auth);
        if (guard != null) return guard;
        if (body.getKeyword() == null || body.getKeyword().isBlank()) {
            return Result.error("搜索词不能为空");
        }
        body.setId(null);
        if (body.getHeat() == null) body.setHeat(0);
        if (body.getStatus() == null) body.setStatus(1);
        if (body.getSortWeight() == null) body.setSortWeight(0);
        LocalDateTime now = LocalDateTime.now();
        body.setCreatedAt(now);
        body.setUpdatedAt(now);
        hotKeywordMapper.insert(body);
        return Result.success(body);
    }

    /** PUT /api/admin/home/keywords/{id} */
    @PutMapping("/keywords/{id}")
    public Object updateKeyword(@RequestHeader(value = "Authorization", required = false) String auth,
                                @PathVariable Long id,
                                @RequestBody HomeHotKeyword body) {
        ResponseEntity<Result<Void>> guard = requireAdmin(auth);
        if (guard != null) return guard;
        HomeHotKeyword exist = hotKeywordMapper.selectById(id);
        if (exist == null) return Result.error("搜索词不存在或已被删除");
        body.setId(id);
        body.setCreatedAt(exist.getCreatedAt());
        body.setUpdatedAt(LocalDateTime.now());
        hotKeywordMapper.updateById(body);
        return Result.success(body);
    }

    /** DELETE /api/admin/home/keywords/{id} */
    @DeleteMapping("/keywords/{id}")
    public Object deleteKeyword(@RequestHeader(value = "Authorization", required = false) String auth,
                                @PathVariable Long id) {
        ResponseEntity<Result<Void>> guard = requireAdmin(auth);
        if (guard != null) return guard;
        hotKeywordMapper.deleteById(id);
        return Result.success();
    }

    /* ============================ 鉴权辅助 ============================ */

    /**
     * 校验管理员身份：令牌有效、未注销、且角色为 ADMIN。
     * 通过返回 null；不通过返回可直接作为响应体的 401 ResponseEntity。
     */
    private ResponseEntity<Result<Void>> requireAdmin(String auth) {
        String token = (auth != null && auth.startsWith("Bearer ")) ? auth.substring(7).trim() : null;
        if (token == null || !JwtUtil.validate(token) || blacklist.contains(token)
                || !JwtUtil.ROLE_ADMIN.equals(JwtUtil.parseRole(token))) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                    .body(Result.error("未登录或登录已过期，请重新登录后台"));
        }
        return null;
    }
}
